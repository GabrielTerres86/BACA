<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 07/06/2010
 * OBJETIVO     : Capturar dados para tela MATRIC
 * --------------
 * ALTERAÇÕES   :
 * 001: [14/02/2011] David   (CECRED) : Não acionar BO quando operação for limpeza da tela ($operacao = '')
 * 002: [09/06/2012] Adriano (CECRED) : Ajustes referente ao projeto GP - Sócios Menores
 * 003: [28/01/2015] Carlos  (CECRED) : #239097 Ajustes para cadastro de Resp. legal 0 menor/maior.
 * 004: [09/07/2015] Gabriel (RKAM)   : Projeto Reformulacao Cadastral.
 * 005: [01/10/2015] Kelvin  (CECRED) : Adicionado nova opção "J" para alteração apenas do cpf/cnpj e removido 
 *									    a possibilidade de alteração pela opção "X", conforme solicitado no 
 *							            chamado 321572.
 * 006: [27/07/2016] Carlos R.(CECRED): Corrigi a forma de utilizacao de indices de informacoes do XML. SD 479874
 * 007: [05/12/2016] Renato D.(Supero): P341-Automatização BACENJUD - Removido passagem do departamento 
 *                                      como parametros pois a BO não utiliza o mesmo.
 * 008: [12/04/2017] Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
 * 009: [26/06/2017] Jonata     (RKAM): Ajustes para inclusão da nova opção "G" (P364).
 * 010: [09/08/2017] Mateus Zimmermann (MOUTS): Ajustes para inclusão do Desligamento (P364).
 * 011: [14/11/2017] Jonata (RKAM)    : Retirado botão de envio TED (P364).
 * 012: [27/12/2017] Renato (Supero)  : Alterado para incluir os botões Desligar e Saque Parcial conforme tela CADMAT (M329)
 * 013: [18/07/2018] Andrey Formigari : Novo campo Nome Social (#SCTASK0017525 - Mouts)
 * 014: [13/02/2019] Rubens Lima (Mouts)  : Novo campo para controle dos botoes Desligar e Saque Parcial (PJ339 - Mouts)
 */ 

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
	$flgConsultar	= (in_array('C', $glbvars['opcoesTela']));	
	$flgIncluir		= (in_array('I', $glbvars['opcoesTela']));
	$flgRelatorio	= (in_array('R', $glbvars['opcoesTela']));
	$flgNome		= (in_array('X', $glbvars['opcoesTela']));
	$flgDesvincula	= (in_array('D', $glbvars['opcoesTela']));	
	$flgCpfCnpj		= (in_array('J', $glbvars['opcoesTela']));	
	$flgAcessoCRM   = 'N';
	$flgDesligarCRM = 'N';
	$flgSaldoPclCRM = 'N';
	$inSaqDes		= '0'; //Indicador saque parcial e desligamento (0-Nao, 1-Sim)
	
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
		$xmlMatric .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
		$xmlMatric .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
		$xmlMatric .= '		<idseqttl>1</idseqttl>';
		$xmlMatric .= '	</Dados>';
		$xmlMatric .= '</Root>';
		
		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResult 	= getDataXML($xmlMatric);
		$xmlObjeto 	= getObjectXML($xmlResult);		
		
		// Se ocorrer um erro, mostra mensagem
		if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
			$operacao = '';
			$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
			$mtdErro  = "showMsgAguardo( 'Aguarde, carregando ...' );setTimeout('controlaVoltar()',1);";		
			
			exibirErro('error',$msgErro,'Alerta - Matric',$mtdErro,false);
		} 
		
		$registro	  = ( isset($xmlObjeto->roottag->tags[0]->tags[0]->tags) ) ? $xmlObjeto->roottag->tags[0]->tags[0]->tags : array();
		$operadoras	  = ( isset($xmlObjeto->roottag->tags[1]->tags) ) ? $xmlObjeto->roottag->tags[1]->tags : array();
		$regFilhos 	  = ( isset($xmlObjeto->roottag->tags[2]->tags) ) ? $xmlObjeto->roottag->tags[2]->tags : array();
		$bens		  = ( isset($xmlObjeto->roottag->tags[3]->tags) ) ? $xmlObjeto->roottag->tags[3]->tags : array();
		$alertas      = ( isset($xmlObjeto->roottag->tags[4]->tags) ) ? $xmlObjeto->roottag->tags[4]->tags : array();
		$responsaveis = ( isset($xmlObjeto->roottag->tags[5]->tags) ) ? $xmlObjeto->roottag->tags[5]->tags : array();
    $titulares 	  = ( isset($xmlObjeto->roottag->tags[6]->tags) ) ? $xmlObjeto->roottag->tags[6]->tags[0] : array();
		$tpPessoa	  = ( getByTagName($registro,'inpessoa') == '' ) ? 1 : getByTagName($registro,'inpessoa');

		//------------
		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResultModalidade = mensageria($xml, "ATENDA", "BUSCA_MODALIDADE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjModalidade = getObjectXML($xmlResultModalidade);

		if (strtoupper($xmlObjModalidade->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObjModalidade->roottag->tags[0]->tags[0]->tags[4]->cdata;
			if ($msgErro == "") {
				$msgErro = $xmlObjModalidade->roottag->tags[0]->cdata;
			}
			exibeErro($msgErro);
		}
		$modalidade = $xmlObjModalidade->roottag->tags[0]->cdata;
		//------------
		
		$msg = Array();
		
		foreach( $alertas as $alerta){
			$msg[getByTagName($alerta->tags,'cdalerta')] = getByTagName($alerta->tags,'dsalerta');
		}
		
		$strMsg = implode( "|", $msg);
				
		// Monta o array dos itens
		?>
		<script type="text/javascript">
		
			arrayFilhosAvtMatric = new Array();
			
			<?php for($i=0; $i<count($regFilhos); $i++) { ?>	
			
				var regFilhoavt<?php echo $i; ?> = new Object();
								
				regFilhoavt<?php echo $i; ?>['nrdctato'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nrdctato'); ?>';
				regFilhoavt<?php echo $i; ?>['cddctato'] = '<?php echo getByTagName($regFilhos[$i]->tags,'cddctato'); ?>';
				regFilhoavt<?php echo $i; ?>['nmdavali'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nmdavali'); ?>';
				regFilhoavt<?php echo $i; ?>['tpdocava'] = '<?php echo getByTagName($regFilhos[$i]->tags,'tpdocava'); ?>';
				regFilhoavt<?php echo $i; ?>['nrdocava'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nrdocava'); ?>';
				regFilhoavt<?php echo $i; ?>['cdoeddoc'] = '<?php echo getByTagName($regFilhos[$i]->tags,'cdoeddoc'); ?>';				
				regFilhoavt<?php echo $i; ?>['cdufddoc'] = '<?php echo getByTagName($regFilhos[$i]->tags,'cdufddoc'); ?>';				
				regFilhoavt<?php echo $i; ?>['dtemddoc'] = '<?php echo getByTagName($regFilhos[$i]->tags,'dtemddoc'); ?>';				
				regFilhoavt<?php echo $i; ?>['dsproftl'] = '<?php echo getByTagName($regFilhos[$i]->tags,'dsproftl'); ?>';				
				regFilhoavt<?php echo $i; ?>['nrcpfcgc'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nrcpfcgc'); ?>';
				regFilhoavt<?php echo $i; ?>['cdcpfcgc'] = '<?php echo getByTagName($regFilhos[$i]->tags,'cdcpfcgc'); ?>';
				regFilhoavt<?php echo $i; ?>['dtvalida'] = '<?php echo getByTagName($regFilhos[$i]->tags,'dtvalida'); ?>';				
				regFilhoavt<?php echo $i; ?>['nrdrowid'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nrdrowid'); ?>';			
				regFilhoavt<?php echo $i; ?>['rowidavt'] = '<?php echo getByTagName($regFilhos[$i]->tags,'rowidavt'); ?>';			
				regFilhoavt<?php echo $i; ?>['dsvalida'] = '<?php if(getByTagName($regFilhos[$i]->tags,'dsvalida') == "12/31/9999"){
														   echo "INDETERMI.";
													     }else{
															echo getByTagName($regFilhos[$i]->tags,'dsvalida');
														 }  ?>';		
				regFilhoavt<?php echo $i; ?>['dtnascto'] = '<?php echo getByTagName($regFilhos[$i]->tags,'dtnascto'); ?>';
				regFilhoavt<?php echo $i; ?>['cdsexcto'] = '<?php echo getByTagName($regFilhos[$i]->tags,'cdsexcto'); ?>';
				regFilhoavt<?php echo $i; ?>['cdestcvl'] = '<?php echo getByTagName($regFilhos[$i]->tags,'cdestcvl'); ?>';
				regFilhoavt<?php echo $i; ?>['dsestcvl'] = '<?php echo getByTagName($regFilhos[$i]->tags,'dsestcvl'); ?>';
				regFilhoavt<?php echo $i; ?>['nrdeanos'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nrdeanos'); ?>';
				regFilhoavt<?php echo $i; ?>['cdnacion'] = '<?php echo getByTagName($regFilhos[$i]->tags,'cdnacion'); ?>';
				regFilhoavt<?php echo $i; ?>['dsnacion'] = '<?php echo getByTagName($regFilhos[$i]->tags,'dsnacion'); ?>';
				regFilhoavt<?php echo $i; ?>['dsnatura'] = '<?php echo getByTagName($regFilhos[$i]->tags,'dsnatura'); ?>';				
				regFilhoavt<?php echo $i; ?>['nmmaecto'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nmmaecto'); ?>';
				regFilhoavt<?php echo $i; ?>['nmpaicto'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nmpaicto'); ?>';
				regFilhoavt<?php echo $i; ?>['nrcepend'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nrcepend'); ?>';
				regFilhoavt<?php echo $i; ?>['dsendres.1'] = '<?php echo getByTagName($regFilhos[$i]->tags[30]->tags,'dsendres.1'); ?>';
				regFilhoavt<?php echo $i; ?>['dsendres.2'] = '<?php echo getByTagName($regFilhos[$i]->tags[30]->tags,'dsendres.2'); ?>';
				regFilhoavt<?php echo $i; ?>['nrendere'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nrendere'); ?>';
				regFilhoavt<?php echo $i; ?>['complend'] = '<?php echo getByTagName($regFilhos[$i]->tags,'complend'); ?>';
				regFilhoavt<?php echo $i; ?>['nmbairro'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nmbairro'); ?>';
				regFilhoavt<?php echo $i; ?>['nmcidade'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nmcidade'); ?>';
				regFilhoavt<?php echo $i; ?>['cdufresd'] = '<?php echo getByTagName($regFilhos[$i]->tags,'cdufresd'); ?>';
			    regFilhoavt<?php echo $i; ?>['dsdrendi.1'] = '<?php echo getByTagName($regFilhos[$i]->tags[5]->tags,'dsdrendi.1'); ?>';
			    regFilhoavt<?php echo $i; ?>['dsdrendi.2'] = '<?php echo getByTagName($regFilhos[$i]->tags[5]->tags,'dsdrendi.2'); ?>';
			    regFilhoavt<?php echo $i; ?>['dsdrendi.3'] = '<?php echo getByTagName($regFilhos[$i]->tags[5]->tags,'dsdrendi.3'); ?>';
			    regFilhoavt<?php echo $i; ?>['dsdrendi.4'] = '<?php echo getByTagName($regFilhos[$i]->tags[5]->tags,'dsdrendi.4'); ?>';
			    regFilhoavt<?php echo $i; ?>['dsdrendi.5'] = '<?php echo getByTagName($regFilhos[$i]->tags[5]->tags,'dsdrendi.5'); ?>';
			    regFilhoavt<?php echo $i; ?>['dsdrendi.6'] = '<?php echo getByTagName($regFilhos[$i]->tags[5]->tags,'dsdrendi.6'); ?>';
			    regFilhoavt<?php echo $i; ?>['dsrelbem.1'] = '<?php echo getByTagName($regFilhos[$i]->tags[51]->tags,'dsrelbem.1'); ?>';
				regFilhoavt<?php echo $i; ?>['dsrelbem.2'] = '<?php echo getByTagName($regFilhos[$i]->tags[51]->tags,'dsrelbem.2'); ?>';
				regFilhoavt<?php echo $i; ?>['dsrelbem.3'] = '<?php echo getByTagName($regFilhos[$i]->tags[51]->tags,'dsrelbem.3'); ?>';
				regFilhoavt<?php echo $i; ?>['dsrelbem.4'] = '<?php echo getByTagName($regFilhos[$i]->tags[51]->tags,'dsrelbem.4'); ?>';
				regFilhoavt<?php echo $i; ?>['dsrelbem.5'] = '<?php echo getByTagName($regFilhos[$i]->tags[51]->tags,'dsrelbem.5'); ?>';
				regFilhoavt<?php echo $i; ?>['dsrelbem.6'] = '<?php echo getByTagName($regFilhos[$i]->tags[51]->tags,'dsrelbem.6'); ?>';
				regFilhoavt<?php echo $i; ?>['persemon.1'] = '<?php echo getByTagName($regFilhos[$i]->tags[52]->tags,'persemon.1'); ?>';
				regFilhoavt<?php echo $i; ?>['persemon.2'] = '<?php echo getByTagName($regFilhos[$i]->tags[52]->tags,'persemon.2'); ?>';
				regFilhoavt<?php echo $i; ?>['persemon.3'] = '<?php echo getByTagName($regFilhos[$i]->tags[52]->tags,'persemon.3'); ?>';
				regFilhoavt<?php echo $i; ?>['persemon.4'] = '<?php echo getByTagName($regFilhos[$i]->tags[52]->tags,'persemon.4'); ?>';
				regFilhoavt<?php echo $i; ?>['persemon.5'] = '<?php echo getByTagName($regFilhos[$i]->tags[52]->tags,'persemon.5'); ?>';
				regFilhoavt<?php echo $i; ?>['persemon.6'] = '<?php echo getByTagName($regFilhos[$i]->tags[52]->tags,'persemon.6'); ?>';
				regFilhoavt<?php echo $i; ?>['qtprebem.1'] = '<?php echo getByTagName($regFilhos[$i]->tags[53]->tags,'qtprebem.1'); ?>';
				regFilhoavt<?php echo $i; ?>['qtprebem.2'] = '<?php echo getByTagName($regFilhos[$i]->tags[53]->tags,'qtprebem.2'); ?>';
				regFilhoavt<?php echo $i; ?>['qtprebem.3'] = '<?php echo getByTagName($regFilhos[$i]->tags[53]->tags,'qtprebem.3'); ?>';
				regFilhoavt<?php echo $i; ?>['qtprebem.4'] = '<?php echo getByTagName($regFilhos[$i]->tags[53]->tags,'qtprebem.4'); ?>';
				regFilhoavt<?php echo $i; ?>['qtprebem.5'] = '<?php echo getByTagName($regFilhos[$i]->tags[53]->tags,'qtprebem.5'); ?>';
				regFilhoavt<?php echo $i; ?>['qtprebem.6'] = '<?php echo getByTagName($regFilhos[$i]->tags[53]->tags,'qtprebem.6'); ?>';
				regFilhoavt<?php echo $i; ?>['vlprebem.1'] = '<?php echo getByTagName($regFilhos[$i]->tags[54]->tags,'vlprebem.1'); ?>';
				regFilhoavt<?php echo $i; ?>['vlprebem.2'] = '<?php echo getByTagName($regFilhos[$i]->tags[54]->tags,'vlprebem.2'); ?>';
				regFilhoavt<?php echo $i; ?>['vlprebem.3'] = '<?php echo getByTagName($regFilhos[$i]->tags[54]->tags,'vlprebem.3'); ?>';
				regFilhoavt<?php echo $i; ?>['vlprebem.4'] = '<?php echo getByTagName($regFilhos[$i]->tags[54]->tags,'vlprebem.4'); ?>';
				regFilhoavt<?php echo $i; ?>['vlprebem.5'] = '<?php echo getByTagName($regFilhos[$i]->tags[54]->tags,'vlprebem.5'); ?>';
				regFilhoavt<?php echo $i; ?>['vlprebem.6'] = '<?php echo getByTagName($regFilhos[$i]->tags[54]->tags,'vlprebem.6'); ?>';
				regFilhoavt<?php echo $i; ?>['vlrdobem.1'] = '<?php echo getByTagName($regFilhos[$i]->tags[55]->tags,'vlrdobem.1'); ?>';
				regFilhoavt<?php echo $i; ?>['vlrdobem.2'] = '<?php echo getByTagName($regFilhos[$i]->tags[55]->tags,'vlrdobem.2'); ?>';
				regFilhoavt<?php echo $i; ?>['vlrdobem.3'] = '<?php echo getByTagName($regFilhos[$i]->tags[55]->tags,'vlrdobem.3'); ?>';
				regFilhoavt<?php echo $i; ?>['vlrdobem.4'] = '<?php echo getByTagName($regFilhos[$i]->tags[55]->tags,'vlrdobem.4'); ?>';
				regFilhoavt<?php echo $i; ?>['vlrdobem.5'] = '<?php echo getByTagName($regFilhos[$i]->tags[55]->tags,'vlrdobem.5'); ?>';
				regFilhoavt<?php echo $i; ?>['vlrdobem.6'] = '<?php echo getByTagName($regFilhos[$i]->tags[55]->tags,'vlrdobem.6'); ?>';
				regFilhoavt<?php echo $i; ?>['nrcxapst'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nrcxapst'); ?>'; 
				regFilhoavt<?php echo $i; ?>['dtadmsoc'] = '<?php echo getByTagName($regFilhos[$i]->tags,'dtadmsoc'); ?>';
				regFilhoavt<?php echo $i; ?>['flgdepec'] = '<?php echo getByTagName($regFilhos[$i]->tags,'flgdepec'); ?>';
				regFilhoavt<?php echo $i; ?>['persocio'] = '<?php echo getByTagName($regFilhos[$i]->tags,'persocio'); ?>';
				regFilhoavt<?php echo $i; ?>['vledvmto'] = '<?php echo getByTagName($regFilhos[$i]->tags,'vledvmto'); ?>';
				regFilhoavt<?php echo $i; ?>['inhabmen'] = '<?php echo getByTagName($regFilhos[$i]->tags,'inhabmen'); ?>';
				regFilhoavt<?php echo $i; ?>['dthabmen'] = '<?php echo getByTagName($regFilhos[$i]->tags,'dthabmen'); ?>';
				regFilhoavt<?php echo $i; ?>['dshabmen'] = '<?php echo getByTagName($regFilhos[$i]->tags,'dshabmen'); ?>';
				regFilhoavt<?php echo $i; ?>['nrctremp'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nrctremp'); ?>';
				regFilhoavt<?php echo $i; ?>['idseqttl'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nrctremp'); ?>';
				regFilhoavt<?php echo $i; ?>['nrdconta'] = '<?php echo getByTagName($regFilhos[$i]->tags,'nrdconta'); ?>';
				regFilhoavt<?php echo $i; ?>['vloutren'] = '<?php echo getByTagName($regFilhos[$i]->tags,'vloutren'); ?>';
				regFilhoavt<?php echo $i; ?>['dsoutren'] = '<?php echo getByTagName($regFilhos[$i]->tags,'dsoutren'); ?>';
				regFilhoavt<?php echo $i; ?>['cdcooper'] = '<?php echo getByTagName($regFilhos[$i]->tags,'cdcooper'); ?>';
				regFilhoavt<?php echo $i; ?>['tpctrato'] = '<?php echo getByTagName($regFilhos[$i]->tags,'tpctrato'); ?>';
				regFilhoavt<?php echo $i; ?>['cddconta'] = '<?php echo getByTagName($regFilhos[$i]->tags,'cddconta'); ?>';
				regFilhoavt<?php echo $i; ?>['dstipcta'] = '<?php echo getByTagName($regFilhos[$i]->tags,'dstipcta'); ?>';
				regFilhoavt<?php echo $i; ?>['dtmvtolt'] = '<?php echo getByTagName($regFilhos[$i]->tags,'dtmvtolt'); ?>';
				regFilhoavt<?php echo $i; ?>['deletado'] = false;
				regFilhoavt<?php echo $i; ?>['cddopcao'] = '<?php echo getByTagName($regFilhos[$i]->tags,'cddopcao'); ?>';
								
				arrayFilhosAvtMatric[<?php echo $i; ?>] = regFilhoavt<?php echo $i; ?>;
				
			<?php } ?>
			
			arrayBensMatric = new Array();
			
			<?php for($i=0; $i<count($bens); $i++) { ?>	
			
				var regBens<?php echo $i; ?> = new Object();
				
				regBens<?php echo $i; ?>['dsrelbem'] = '<?php echo getByTagName($bens[$i]->tags,'dsrelbem'); ?>';			
				regBens<?php echo $i; ?>['persemon'] = '<?php echo getByTagName($bens[$i]->tags,'persemon'); ?>';			
				regBens<?php echo $i; ?>['qtprebem'] = '<?php echo getByTagName($bens[$i]->tags,'qtprebem'); ?>';			
				regBens<?php echo $i; ?>['vlprebem'] = '<?php echo getByTagName($bens[$i]->tags,'vlprebem'); ?>';			
				regBens<?php echo $i; ?>['cdsequen'] = '<?php echo getByTagName($bens[$i]->tags,'cdsequen'); ?>';			
				regBens<?php echo $i; ?>['vlrdobem'] = '<?php echo getByTagName($bens[$i]->tags,'vlrdobem'); ?>';			
				regBens<?php echo $i; ?>['nrdrowid'] = '<?php echo getByTagName($bens[$i]->tags,'nrdrowid'); ?>';			
				regBens<?php echo $i; ?>['cpfdoben'] = '<?php echo getByTagName($bens[$i]->tags,'cpfdoben'); ?>';			
				regBens<?php echo $i; ?>['deletado'] = false;				
				regBens<?php echo $i; ?>['cddopcao'] = '<?php echo getByTagName($bens[$i]->tags,'cddopcao'); ?>';			
								
				arrayBensMatric[<?php echo $i; ?>] = regBens<?php echo $i; ?>;
				 
			<?php } ?>			
			
			arrayFilhos = new Array();

			<?php for($i=0; $i<count($responsaveis); $i++) { ?>	
			
				var regResp<?php echo $i; ?> = new Object();
				
				regResp<?php echo $i; ?>['cdcooper'] = '<?php echo getByTagName($responsaveis[$i]->tags,'cdcooper'); ?>';
				regResp<?php echo $i; ?>['nrctamen'] = '<?php echo getByTagName($responsaveis[$i]->tags,'nrctamen'); ?>';
				regResp<?php echo $i; ?>['nrcpfmen'] = '<?php echo getByTagName($responsaveis[$i]->tags,'nrcpfmen'); ?>';
				regResp<?php echo $i; ?>['idseqmen'] = '<?php echo getByTagName($responsaveis[$i]->tags,'idseqmen'); ?>';				
				regResp<?php echo $i; ?>['nrdconta'] = '<?php echo getByTagName($responsaveis[$i]->tags,'nrdconta'); ?>';				
				regResp<?php echo $i; ?>['nrcpfcgc'] = '<?php echo getByTagName($responsaveis[$i]->tags,'nrcpfcgc'); ?>';
				regResp<?php echo $i; ?>['nmrespon'] = '<?php echo getByTagName($responsaveis[$i]->tags,'nmrespon'); ?>';				
				regResp<?php echo $i; ?>['nridenti'] = '<?php echo getByTagName($responsaveis[$i]->tags,'nridenti'); ?>';				
				regResp<?php echo $i; ?>['tpdeiden'] = '<?php echo getByTagName($responsaveis[$i]->tags,'tpdeiden'); ?>';				
				regResp<?php echo $i; ?>['dsorgemi'] = '<?php echo getByTagName($responsaveis[$i]->tags,'dsorgemi'); ?>';				
				regResp<?php echo $i; ?>['cdufiden'] = '<?php echo getByTagName($responsaveis[$i]->tags,'cdufiden'); ?>';
				regResp<?php echo $i; ?>['dtemiden'] = '<?php echo getByTagName($responsaveis[$i]->tags,'dtemiden'); ?>';				
				regResp<?php echo $i; ?>['dtnascin'] = '<?php echo getByTagName($responsaveis[$i]->tags,'dtnascin'); ?>';				
				regResp<?php echo $i; ?>['cddosexo'] = '<?php echo getByTagName($responsaveis[$i]->tags,'cddosexo'); ?>';			
				regResp<?php echo $i; ?>['cdestciv'] = '<?php echo getByTagName($responsaveis[$i]->tags,'cdestciv'); ?>';
				regResp<?php echo $i; ?>['cdnacion'] = '<?php echo getByTagName($responsaveis[$i]->tags,'cdnacion'); ?>';
				regResp<?php echo $i; ?>['dsnacion'] = '<?php echo getByTagName($responsaveis[$i]->tags,'dsnacion'); ?>';
				regResp<?php echo $i; ?>['dsnatura'] = '<?php echo getByTagName($responsaveis[$i]->tags,'dsnatura'); ?>';
				regResp<?php echo $i; ?>['cdcepres'] = '<?php echo getByTagName($responsaveis[$i]->tags,'cdcepres'); ?>';				
				regResp<?php echo $i; ?>['dsendres'] = '<?php echo getByTagName($responsaveis[$i]->tags,'dsendres'); ?>';				
				regResp<?php echo $i; ?>['nrendres'] = '<?php echo getByTagName($responsaveis[$i]->tags,'nrendres'); ?>';				
				regResp<?php echo $i; ?>['dscomres'] = '<?php echo getByTagName($responsaveis[$i]->tags,'dscomres'); ?>';				
				regResp<?php echo $i; ?>['dsbaires'] = '<?php echo getByTagName($responsaveis[$i]->tags,'dsbaires'); ?>';				
				regResp<?php echo $i; ?>['nrcxpost'] = '<?php echo getByTagName($responsaveis[$i]->tags,'nrcxpost'); ?>';				
				regResp<?php echo $i; ?>['dscidres'] = '<?php echo getByTagName($responsaveis[$i]->tags,'dscidres'); ?>';				
				regResp<?php echo $i; ?>['dsdufres'] = '<?php echo getByTagName($responsaveis[$i]->tags,'dsdufres'); ?>';				
				regResp<?php echo $i; ?>['nmpairsp'] = '<?php echo getByTagName($responsaveis[$i]->tags,'nmpairsp'); ?>';
				regResp<?php echo $i; ?>['nmmaersp'] = '<?php echo getByTagName($responsaveis[$i]->tags,'nmmaersp'); ?>';
				regResp<?php echo $i; ?>['deletado'] = '<?php echo getByTagName($responsaveis[$i]->tags,'deletado'); ?>';
				regResp<?php echo $i; ?>['cddopcao'] = '<?php echo getByTagName($responsaveis[$i]->tags,'cddopcao'); ?>';
				regResp<?php echo $i; ?>['nrdrowid'] = '<?php echo getByTagName($responsaveis[$i]->tags,'nrdrowid'); ?>';
				regResp<?php echo $i; ?>['cddctato'] = '<?php echo getByTagName($responsaveis[$i]->tags,'cddctato'); ?>';
				regResp<?php echo $i; ?>['dsestcvl'] = '<?php echo getByTagName($responsaveis[$i]->tags,'dsestcvl'); ?>';
				regResp<?php echo $i; ?>['dtmvtolt'] = '<?php echo getByTagName($responsaveis[$i]->tags,'dtmvtolt'); ?>';

				arrayFilhos[<?php echo $i; ?>] = regResp<?php echo $i; ?>;

			<?php } ?>			
			
			sincronizaArray();
			
		</script>
	
		<?php
	
	include('form_fisico.php'); 
	include('form_juridico.php');
	
	if ($cddopcao == 'C') {
	    // Monta o xml de requisição
		$xml   = "";
		$xml  .= "<Root>";
		$xml  .= "  <Dados>";
		$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
		$xml  .= "  </Dados>";
		$xml  .= "</Root>";

		// Executa script para envio do XML  -- Passa como agencia o cdpactra, pois a agencia está sempre com valor zero
		$xmlResult = mensageria($xml, "MATRIC", "ACESSO_OPERADOR_CRM", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);

		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {

			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        
			exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','fechaRotina($(\'#divRotina\'));',false);

		}

		// Ler os flags do XML
		$flgAcessoCRM   = $xmlObj->roottag->tags[0]->cdata;
		$flgDesligarCRM = $xmlObj->roottag->tags[1]->cdata;
		$flgSaldoPclCRM = $xmlObj->roottag->tags[2]->cdata;
		$inSaqDes	    = $xmlObj->roottag->tags[3]->cdata;
		
	}
?>

<div id="divBotoes" style="margin-bottom:10px">

	<a href="#" class="opInicial botao" id="btLimparIni" onclick="controlaVoltar(); return false;">Limpar</a>
	<a href="#" class="opInicial botao" id="btProsseguirIni" onclick="consultaInicial(); return false;">Prosseguir</a>

	<a href="#" class="opIncluir botao" id="btVoltarInc" onclick="controlaOperacao('IC'); return false;">Voltar</a>
	<a href="#" class="opIncluir botao" id="btProsseguirInc" onclick="">Prosseguir</a>
											
	<a href="#" class="opPreIncluir botao" id="btVoltarPreInc" onclick="controlaVoltar(); return false;">Voltar</a>
	<a href="#" class="opPreIncluir botao" id="btProsseguirPreInc" onclick="">Prosseguir</a>

	

	<a href="#" class="opAltNome botao" id="btVoltarAltNome" onclick="controlaOperacao('XC'); return false;">Cancelar</a>
	<a href="#" class="opAltNome botao" id="btSalvarAltNome" onclick="controlaOperacao('XV'); return false;">Concluir</a>
	
	<a href="#" class="opAltCpfCnpj botao" id="btVoltarAltCpfCnpj" onclick="controlaOperacao('JC'); return false;">Cancelar</a>
	<a href="#" class="opAltCpfCnpj botao" id="btSalvarAltCpfCnpj" onclick="controlaOperacao('JV'); return false;">Concluir</a>
	
	<a href="#" class="opConsultar botao" id="btVoltarCns">Voltar</a>	  
<!-- Utiliza classes diferentes para que o foco não se posicione no botão errado -->
	<a href="#" class="opBtnCRM    botao" id="btDemissCRM"     onclick="verificaProdutosAtivosCRM();">Desligar</a>
	<a href="#" class="opBtnCRM    botao" id="btSaqueCRM"      onclick="abrirRotinaSaqueParcialCRM();">Saque Parcial</a>
	<a href="#" class="opBtnCRM    botao" id="btDesligarAlt" onclick="verificaProdutosAtivos();return false;">Desligar</a>
	
	<? if (getByTagName($registro,'flgtermo') == '1'){?>
		
		<a href="#" class="botao" id="btTermoDesligamento" onclick="showError('inform','Termo de desligamento j&aacute; est&aacute; digitalizado no SmartShare? <? if (getByTagName($registro,'flgdigit') == '1') { echo 'Sim.'; }else{ echo 'N&atilde;o.'; } ?> ','Alerta - Aimaro','');">Termo Cancelamento</a>

	<?}?>
  
    <? if(getByTagName($registro,'dtdemiss') == ''){?>
		
		
        <a href="#" class="botao" id="btSaqueParcial" >Saque Parcial</a>
  
	<?}?>
	
	

	<a href="#" class="opConsultar botao" id="btProsseguirCns" >Prosseguir</a>
	
	<a href="#" class="opDesvinc botao" id="btVoltarDesvinc" onclick="controlaOperacao('DC'); return false;">Cancelar</a>
	<a href="#" class="opDesvinc botao" id="btSalvarDesvinc" onclick="controlaOperacao('DV'); return false;">Concluir</a>
	
    
</div>

<script type='text/javascript'>

	// Alimenta as variáveis globais
	operacao = '<?php echo $operacao; ?>';
	nrdconta = '<?php echo $nrdconta; ?>';
	
	if(operacao == 'CI'){
	
		if($("#pessoaFi", "#frmFiltro").prop("checked") == true){
			
			tppessoa = 1;
			
		}else if($("#pessoaJu", "#frmFiltro").prop("checked") == true){
			
			tppessoa = 2;
			
		}
		
	}else{
	
	tppessoa = '<?php echo $tpPessoa; ?>';	
		$('#rowidass','#frmFiltro').val("<?php echo ( isset($registro) ) ? getByTagName($registro,'rowidass') : ''; ?>");
		$('#inmatric','#frmFiltro').val("<?php echo ( isset($registro) ) ? getByTagName($registro,'inmatric') : ''; ?>");
		$('#cdagepac','#frmFiltro').val("<?php echo getByTagName($registro,'cdagepac') ?>");
		$('#nmresage','#frmFiltro').val("<?php echo getByTagName($registro,'nmresage') ?>");
		$('#nrmatric','#frmFiltro').val("<?php echo getByTagName($registro,'nrmatric') ?>");
		
		<?if($tpPessoa == 1){?>
		
			$('#pessoaFi','#frmFiltro').prop("checked",true);
			$('#pessoaJu','#frmFiltro').prop("checked",false);
			
		<?}else if($tpPessoa == 2 || $tppessoa == 3){?>
		
			$('#pessoaFi','#frmFiltro').prop("checked",false);
			$('#pessoaJu','#frmFiltro').prop("checked",true);
			
		<?}?>
		
	}
	
	nrdeanos = '<?php echo getByTagName($registro,'nrdeanos'); ?>';
	dtmvtolt = '<?php echo $glbvars["dtmvtolt"] ?>';
	
	// Alimenta opções que o operador tem acesso	
	flgConsultar	= '<?php echo $flgConsultar; 	?>';
	flgIncluir		= '<?php echo $flgIncluir; 	?>';
	flgRelatorio	= '<?php echo $flgRelatorio; 	?>';
	flgNome			= '<?php echo $flgNome; 		?>';
	flgDesvincula	= '<?php echo $flgDesvincula;	?>';
    flgCpfCnpj      = '<?php echo $flgCpfCnpj;	    ?>';
	flgAcessoCRM    = '<?php echo $flgAcessoCRM;    ?>';
	flgDesligarCRM  = '<?php echo $flgDesligarCRM;  ?>';
	flgSaldoPclCRM  = '<?php echo $flgSaldoPclCRM;  ?>';
	inSaqDes 		= '<?php echo $inSaqDes;  		?>';
	
	strMsg = '<?php echo $strMsg; ?>';
	
	controlaApresentacaoForms();
		
	if (operacao != 'CI') {
		if ( strMsg != '' ){
			exibirMensagens(strMsg,'controlaFoco();');
		}else{
			controlaFoco();	
		}
		if (tppessoa == 2) {
			$("#cdcnae","#frmJuridico").trigger("change");	
		}
	}else{
		
		consultaPreIncluir();	
		
	}
	
</script>
