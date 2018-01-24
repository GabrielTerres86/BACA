<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jorge I. Hamaguchi 
 * DATA CRIAÇÃO : 14/08/2013
 * OBJETIVO     : Rotina tela PARMON.
 * --------------
 * ALTERAÇÕES   : 20/10/2014 - Novos campos. Chamado 198702 (Jonata-RKAM).
 *
 *                06/04/2016 - Adicionado campos de TED. (Jaison/Marcos - SUPERO)
 *
 *                24/05/2016 - Inclusão do novo parâmetro (flmntage) de monitoração de agendamento (Carlos)
 *
 *				  01/11/2017 - Melhoria 458 Prevenção Lavagem de Dinheiro (junior - Mouts)
 * -------------- 
 */
?> 

<?	
	session_cache_limiter("private");
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$vlinimon = (isset($_POST['vlinimon'])) ? $_POST['vlinimon'] : 0 ;
	$vllmonip = (isset($_POST['vllmonip'])) ? $_POST['vllmonip'] : 0 ;
	$vlinisaq = (isset($_POST['vlinisaq'])) ? $_POST['vlinisaq'] : 0 ;
	$vlinitrf = (isset($_POST['vlinitrf'])) ? $_POST['vlinitrf'] : 0 ;
	$vlsaqind = (isset($_POST['vlsaqind'])) ? $_POST['vlsaqind'] : 0 ;
	$insaqlim = (isset($_POST['insaqlim'])) ? $_POST['insaqlim'] : 0 ;
	$inaleblq = (isset($_POST['inaleblq'])) ? $_POST['inaleblq'] : 0 ;
    $vlmnlmtd = (isset($_POST['vlmnlmtd'])) ? $_POST['vlmnlmtd'] : 0 ;
    $vlinited = (isset($_POST['vlinited'])) ? $_POST['vlinited'] : 0 ;
    $flmstted = (isset($_POST['flmstted'])) ? $_POST['flmstted'] : 0 ;
    $flnvfted = (isset($_POST['flnvfted'])) ? $_POST['flnvfted'] : 0 ;
    $flmobted = (isset($_POST['flmobted'])) ? $_POST['flmobted'] : 0 ;
    $dsestted = (isset($_POST['dsestted'])) ? $_POST['dsestted'] : '' ;
	$flmntage = (isset($_POST['flmntage'])) ? $_POST['flmntage'] : 0 ;

	$qtrendadiariopf 			= (isset($_POST['qtrendadiariopf'])) 			? $_POST['qtrendadiariopf'] : 0 ;
	$qtrendadiariopj 			= (isset($_POST['qtrendadiariopj'])) 			? $_POST['qtrendadiariopj'] : 0 ;
	$vlcreditodiariopf 			= (isset($_POST['vlcreditodiariopf'])) 			? $_POST['vlcreditodiariopf'] : 0 ;		
	$vlcreditodiariopj 			= (isset($_POST['vlcreditodiariopj'])) 			? $_POST['vlcreditodiariopj'] : 0 ;
	$qtrendamensalpf 			= (isset($_POST['qtrendamensalpf'])) 			? $_POST['qtrendamensalpf'] : 0 ;
	$qtrendamensalpj 			= (isset($_POST['qtrendamensalpj'])) 			? $_POST['qtrendamensalpj'] : 0 ;
	$vlcreditomensalpf 			= (isset($_POST['vlcreditomensalpf'])) 			? $_POST['vlcreditomensalpf'] : 0 ;
	$vlcreditomensalpj 			= (isset($_POST['vlcreditomensalpj'])) 			? $_POST['vlcreditomensalpj'] : 0 ;
	$vllimitesaque 				= (isset($_POST['vllimitesaque'])) 				? $_POST['vllimitesaque'] : 0 ;
	$inrendazerada 				= (isset($_POST['inrendazerada'])) 				? $_POST['inrendazerada'] : 0 ;
	$vllimitedeposito 			= (isset($_POST['vllimitedeposito'])) 			? $_POST['vllimitedeposito'] : 0 ;
	$vllimitepagamento 			= (isset($_POST['vllimitepagamento'])) 			? $_POST['vllimitepagamento'] : 0 ;
	$vlprovisaoemail 			= (isset($_POST['vlprovisaoemail'])) 			? $_POST['vlprovisaoemail'] : 0 ;
	$vlprovisaosaque 			= (isset($_POST['vlprovisaosaque'])) 			? $_POST['vlprovisaosaque'] : 0 ;
	$vlmonpagto 				= (isset($_POST['vlmonpagto'])) 				? $_POST['vlmonpagto'] : 0 ;
	$qtdiasprovisao 			= (isset($_POST['qtdiasprovisao'])) 			? $_POST['qtdiasprovisao'] : 0 ;
	$hrlimiteprovisao 			= (isset($_POST['hrlimiteprovisao'])) 			? $_POST['hrlimiteprovisao'] : 0 ;
	$qtdiasprovisaocancelamento = (isset($_POST['qtdiasprovisaocancelamento'])) ? $_POST['qtdiasprovisaocancelamento'] : 0 ; 
	$inliberasaque 				= (isset($_POST['inliberasaque'])) 				? $_POST['inliberasaque'] : 0 ; 
	$inliberaprovisaosaque 		= (isset($_POST['inliberaprovisaosaque'])) 		? $_POST['inliberaprovisaosaque'] : 0 ; 
	$inalteraprovisaopresencial = (isset($_POST['inalteraprovisaopresencial'])) ? $_POST['inalteraprovisaopresencial'] : 0 ; 
	$inverificasaldo 			= (isset($_POST['inverificasaldo'])) 			? $_POST['inverificasaldo'] : 0 ; 
	$dsemailcoop 				= (isset($_POST['dsdemailseg'])) 				? $_POST['dsdemailseg'] : '' ;
	$dsdeemail 					= (isset($_POST['dsdeemail'])) 					? $_POST['dsdeemail'] : '' ;

	$cdcoptel = (isset($_POST['cdcoptel'])) ? $_POST['cdcoptel'] : $glbvars['cdcooper'];
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	$realopcao      = '';
	
	$nmendter = session_id();
	
	// Verifica Procedure a ser executada	
	switch($cddopcao) {
		case 'C' : { $realopcao = 'C'; $procedure = 'consultar_parmon'; break; }
		case 'C1': { $realopcao = 'C'; $procedure = 'consultar_parmon'; break; }
		case 'A' : { $realopcao = 'A'; $procedure = 'consultar_parmon'; break; }
		case 'A1': { $realopcao = 'A'; $procedure = 'alterar_parmon';   break; }
		case 'A2': { $realopcao = 'A2'; $procedure = 'ALTERA_PARMON_PLD';   break; }
		case 'AP': { $realopcao = 'AP'; $procedure = 'CONSULTA_PARMON_PLD';   break; }
		case 'CP': { $realopcao = 'CP'; $procedure = 'CONSULTA_PARMON_PLD';   break; }
		case 'C2': { $realopcao = 'CP'; $procedure = 'CONSULTA_PARMON_PLD'; break; }
		default  : { exibirErro('atencao','Op&ccedil;&atilde;o Invalida!','Alerta - Ayllos','',false); }
	}
	
	$vr_aux = $realopcao;

	if($realopcao == 'A2'){
		$realopcao = 'A';
	}	

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$realopcao)) <> '') {		
		exibirErro('atencao',$msgError,'Alerta - Ayllos','',false);
	}
	
	$realopcao = $vr_aux;
	
	if($cddopcao == "A1" || $cddopcao == "A2"){
		$cdcoptel = implode("|",$cdcoptel);
	}
	
	if($cdcoptel == ''){
		$cdcoptel = $glbvars['cdcooper'];
		if($cdcoptel == "3"){
			$cdcoptel = "1";
		}
	}
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	if($realopcao=='A' || $realopcao == 'C'){
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0016.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<vlinimon>'.$vlinimon.'</vlinimon>';
	$xml .= '		<vllmonip>'.$vllmonip.'</vllmonip>';
	$xml .= '		<vlinisaq>'.$vlinisaq.'</vlinisaq>';
	$xml .= '		<vlinitrf>'.$vlinitrf.'</vlinitrf>';
	$xml .= '		<vlsaqind>'.$vlsaqind.'</vlsaqind>';
	$xml .= '		<insaqlim>'.$insaqlim.'</insaqlim>';
	$xml .= '		<inaleblq>'.$inaleblq.'</inaleblq>';
	$xml .= '		<cdcoptel>'.$cdcoptel.'</cdcoptel>';
    $xml .= '		<vlmnlmtd>'.$vlmnlmtd.'</vlmnlmtd>';
    $xml .= '		<vlinited>'.$vlinited.'</vlinited>';
    $xml .= '		<flmstted>'.($flmstted == 1 ? 'yes' : 'no').'</flmstted>';
    $xml .= '		<flnvfted>'.($flnvfted == 1 ? 'yes' : 'no').'</flnvfted>';
    $xml .= '		<flmobted>'.($flmobted == 1 ? 'yes' : 'no').'</flmobted>';
	$xml .= '		<flmntage>'.($flmntage == 1 ? 'yes' : 'no').'</flmntage>';
    $xml .= '		<dsestted>'.$dsestted.'</dsestted>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
    // Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	$xmlObj    = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
 	if ($xmlObj->roottag->tags[0]->name == "ERRO") {
		$msgerro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		echo "showError('error','".$msgerro."','Alerta - Ayllos','$(\"#btVoltar\",\"#divBotoes\").click();hideMsgAguardo();');";
		exit();
    }
	}	

	if($realopcao == 'AP' || $realopcao == 'A2' || $realopcao == 'CP'){
		if($realopcao == 'A2'){
			$realopcao = 'AP';

			$vlcreditodiariopf 		= str_replace(',','.',str_replace('.','',$vlcreditodiariopf));
			$vlcreditodiariopj 		= str_replace(',','.',str_replace('.','',$vlcreditodiariopj));
			$vlcreditomensalpf 		= str_replace(',','.',str_replace('.','',$vlcreditomensalpf));
			$vlcreditomensalpj 		= str_replace(',','.',str_replace('.','',$vlcreditomensalpj));
			$vllimitesaque 	   		= str_replace(',','.',str_replace('.','',$vllimitesaque));
			$vllimitedeposito  		= str_replace(',','.',str_replace('.','',$vllimitedeposito));
			$vllimitepagamento 		= str_replace(',','.',str_replace('.','',$vllimitepagamento));
			$vlprovisaoemail   		= str_replace(',','.',str_replace('.','',$vlprovisaoemail));
			$vlprovisaosaque   		= str_replace(',','.',str_replace('.','',$vlprovisaosaque));
			$vlmonpagto   			= str_replace(',','.',str_replace('.','',$vlmonpagto));
			$hrlimiteprovisao      = str_replace(':','',$hrlimiteprovisao);

			$xml = "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
			$xml .= "   <cdcoptel>" . $cdcoptel . "</cdcoptel>";
			$xml .= "   <qtrenda_diario_pf>".$qtrendadiariopf."</qtrenda_diario_pf>";
			$xml .= "   <qtrenda_diario_pj>" . $qtrendadiariopj . "</qtrenda_diario_pj>";
			$xml .= "   <vlcredito_diario_pf>" . $vlcreditodiariopf . "</vlcredito_diario_pf>";
			$xml .= "   <vlcredito_diario_pj>" . $vlcreditodiariopj . "</vlcredito_diario_pj>";
			$xml .= "   <qtrenda_mensal_pf>" . $qtrendamensalpf . "</qtrenda_mensal_pf>";
			$xml .= "   <qtrenda_mensal_pj>" . $qtrendamensalpj . "</qtrenda_mensal_pj>";
			$xml .= "   <vlcredito_mensal_pf>" . $vlcreditomensalpf . "</vlcredito_mensal_pf>";
			$xml .= "   <vlcredito_mensal_pj>" . $vlcreditomensalpj . "</vlcredito_mensal_pj>";
			$xml .= "   <inrenda_zerada>" . $inrendazerada . "</inrenda_zerada>";
			$xml .= "   <vllimite_saque>" . $vllimitesaque . "</vllimite_saque>";
			$xml .= "   <vllimite_deposito>" . $vllimitedeposito . "</vllimite_deposito>";
			$xml .= "   <vllimite_pagamento>" . $vllimitepagamento . "</vllimite_pagamento>";
			$xml .= "   <vlprovisao_email>" . $vlprovisaoemail . "</vlprovisao_email>";
			$xml .= "   <vlprovisao_saque>" . $vlprovisaosaque . "</vlprovisao_saque>";			
			$xml .= "   <vlmon_pagto>" . $vlmonpagto . "</vlmon_pagto>";
			$xml .= "   <qtdias_provisao>" . $qtdiasprovisao . "</qtdias_provisao>";
			$xml .= "   <hrlimite_provisao>" . $hrlimiteprovisao . "</hrlimite_provisao>";
			$xml .= "   <qtdias_prov_cancelamento>" . $qtdiasprovisaocancelamento . "</qtdias_prov_cancelamento>";
			$xml .= "   <inlibera_saque>" . $inliberasaque. "</inlibera_saque>";
			$xml .= "   <inlibera_provisao_saque>" . $inliberaprovisaosaque . "</inlibera_provisao_saque>";
			$xml .= "   <inaltera_prov_presencial>" . $inalteraprovisaopresencial . "</inaltera_prov_presencial>";
			$xml .= "   <inverifica_saldo>" . $inverificasaldo . "</inverifica_saldo>";
			$xml .= "   <dsdemail>" . $dsdeemail . "</dsdemail>";	
			$xml .= "   <dsemailcoop>" . $dsemailcoop . "</dsemailcoop>";				
			$xml .= " </Dados>";
			$xml .= "</Root>";				

		}else{
			$xml = "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
			$xml .= "   <cdcoptel>" . $cdcoptel . "</cdcoptel>";			
			$xml .= " </Dados>";
			$xml .= "</Root>";					
		}
		
		#echo 'console.log("'.$xml.'");';
		$xmlResult = mensageria($xml, "TELA_PARMON", $procedure, $glbvars["cdcooper"],1, 1, $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");				
		#echo 'console.log("'.$xmlResult.'");';
		$xmlObj = getObjectXML($xmlResult);	

	}    
	
	$xmlObj = simplexml_load_string($xmlResult);
		
	if($realopcao =='A' || $realopcao == 'C'){	
	$vlinimon = $xmlObj->PARMON->Registro->vlinimon;
	$vllmonip = $xmlObj->PARMON->Registro->vllmonip;
	$vlinisaq = $xmlObj->PARMON->Registro->vlinisaq;
	$vlinitrf = $xmlObj->PARMON->Registro->vlinitrf;
	$vlsaqind = $xmlObj->PARMON->Registro->vlsaqind;
	$insaqlim = $xmlObj->PARMON->Registro->insaqlim;
	$inaleblq = $xmlObj->PARMON->Registro->inaleblq;
    $vlmnlmtd = $xmlObj->PARMON->Registro->vlmnlmtd;
    $vlinited = $xmlObj->PARMON->Registro->vlinited;
    $flmstted = $xmlObj->PARMON->Registro->flmstted;
    $flnvfted = $xmlObj->PARMON->Registro->flnvfted;
    $flmobted = $xmlObj->PARMON->Registro->flmobted;
    $dsestted = $xmlObj->PARMON->Registro->dsestted;
	$flmntage = $xmlObj->PARMON->Registro->flmntage;
	}

	if($realopcao == 'AP' || $realopcao == 'CP'){
		$qtrendadiariopf 			= empty($xmlObj->Dados->inf->qtrenda_diario_pf)?0:$xmlObj->Dados->inf->qtrenda_diario_pf;
		$qtrendadiariopj 			= empty($xmlObj->Dados->inf->qtrenda_diario_pj)?0:$xmlObj->Dados->inf->qtrenda_diario_pj;
		$vlcreditodiariopf 			= empty($xmlObj->Dados->inf->vlcredito_diario_pf)?0:$xmlObj->Dados->inf->vlcredito_diario_pf;
		$vlcreditodiariopj 			= empty($xmlObj->Dados->inf->vlcredito_diario_pj)?0:$xmlObj->Dados->inf->vlcredito_diario_pj;
		$qtrendamensalpf 			= empty($xmlObj->Dados->inf->qtrenda_mensal_pf)?0:$xmlObj->Dados->inf->qtrenda_mensal_pf;
		$qtrendamensalpj 			= empty($xmlObj->Dados->inf->qtrenda_mensal_pj)?0:$xmlObj->Dados->inf->qtrenda_mensal_pj;
		$vlcreditomensalpf 			= empty($xmlObj->Dados->inf->vlcredito_mensal_pf)?0:$xmlObj->Dados->inf->vlcredito_mensal_pf;
		$vlcreditomensalpj 			= empty($xmlObj->Dados->inf->vlcredito_mensal_pj)?0:$xmlObj->Dados->inf->vlcredito_mensal_pj;
		$vllimitesaque 				= empty($xmlObj->Dados->inf->vllimite_saque)?0:$xmlObj->Dados->inf->vllimite_saque;
		$inrendazerada 				= empty($xmlObj->Dados->inf->inrenda_zerada)?0:$xmlObj->Dados->inf->inrenda_zerada;
		$vllimitedeposito 			= empty($xmlObj->Dados->inf->vllimite_deposito)?0:$xmlObj->Dados->inf->vllimite_deposito;
		$vllimitepagamento 			= empty($xmlObj->Dados->inf->vllimite_pagamento)?0:$xmlObj->Dados->inf->vllimite_pagamento;
		$vlprovisaoemail 			= empty($xmlObj->Dados->inf->vlprovisao_email)?0:$xmlObj->Dados->inf->vlprovisao_email;
		$vlprovisaosaque 			= empty($xmlObj->Dados->inf->vlprovisao_saque)?0:$xmlObj->Dados->inf->vlprovisao_saque;		
		$vlmonpagto 				= empty($xmlObj->Dados->inf->vlmonitoracao_pagamento)?0:$xmlObj->Dados->inf->vlmonitoracao_pagamento;		
		$qtdiasprovisao 			= empty($xmlObj->Dados->inf->qtdias_provisao)?0:$xmlObj->Dados->inf->qtdias_provisao;
		$hrlimiteprovisao 			= empty($xmlObj->Dados->inf->hrlimite_provisao)?0:$xmlObj->Dados->inf->hrlimite_provisao;
		$qtdiasprovisaocancelamento = empty($xmlObj->Dados->inf->qtdias_provisao_cancelamento)?0:$xmlObj->Dados->inf->qtdias_provisao_cancelamento;
		$inliberasaque 				= empty($xmlObj->Dados->inf->inlibera_saque)?0:$xmlObj->Dados->inf->inlibera_saque;
		$inliberaprovisaosaque 		= empty($xmlObj->Dados->inf->inlibera_provisao_saque)?0:$xmlObj->Dados->inf->inlibera_provisao_saque;
		$inalteraprovisaopresencial = empty($xmlObj->Dados->inf->inaltera_provisao_presencial)?0:$xmlObj->Dados->inf->inaltera_provisao_presencial;
		$inverificasaldo 			= empty($xmlObj->Dados->inf->inverifica_saldo)?0:$xmlObj->Dados->inf->inverifica_saldo;
		$dsdemailseg 				= empty($xmlObj->Dados->inf->dsdemailseg)?'':$xmlObj->Dados->inf->dsdemailseg;
		$dsdeemail 					= empty($xmlObj->Dados->inf->dsdemail)?'':$xmlObj->Dados->inf->dsdemail;

		if(strlen($hrlimiteprovisao)==4){
			$hrlimiteprovisao = substr($hrlimiteprovisao,0,2).':'.substr($hrlimiteprovisao,2,2);			
		}	
	}
	
	$coops    = $xmlObj->CRAPCOP->Registro;
	
	if ($cddopcao == "C" or $cddopcao == "C1" or $cddopcao == "A" or $cddopcao == 'AP' or $cddopcao == 'CP' or $cddopcao == 'C2'){
		
		$desab = ($cddopcao == "C" or $cddopcao == "C1" or $cddopcao == "CP" or $cddopcao == "C2") ? ".desabilitaCampo()" : ".habilitaCampo()";
		$btcon = ($cddopcao == "C" or $cddopcao == "C1" or $cddopcao == "CP" or $cddopcao == "C2") ? "$('#btSalvar').hide();" : "";
		
		if($cddopcao == "A" || $cddopcao == "AP"){
			$focus = ($cddopcao == "A")?"$('#vlinimon','#frmparmon').focus();":"$('#vlrendadpf','#frmparmon').focus();";
		}else{
			$focus = "$('#btVoltar','#divBotoes').focus();";;
		}
		//FRAUDES
	if ($cddopcao == "C" or $cddopcao == "C1" or $cddopcao == "A"){
		echo "$('#vlinimon','#frmparmon').val('".formataMoeda($vlinimon)."')".$desab.";";
		echo "$('#vllmonip','#frmparmon').val('".formataMoeda($vllmonip)."')".$desab.";";
		echo "$('#vlinisaq','#frmparmon').val('".formataMoeda($vlinisaq)."')".$desab.";";
		echo "$('#vlinitrf','#frmparmon').val('".formataMoeda($vlinitrf)."')".$desab.";";
		echo "$('#vlsaqind','#frmparmon').val('".formataMoeda($vlsaqind)."')".$desab.";";
		echo "$('#vlmnlmtd','#frmparmon').val('".formataMoeda($vlmnlmtd)."')".$desab.";";
		echo "$('#vlinited','#frmparmon').val('".formataMoeda($vlinited)."')".$desab.";";
        echo "$('#dsestted','#frmparmon').val('".$dsestted."');";
		
		if ($insaqlim == '1') {
			echo "$('input:radio[name=insaqlim][value=1]').attr('checked', true)" . $desab . ";";
			echo "$('input:radio[name=insaqlim][value=0]')" . $desab . ";";
		} else {
			echo "$('input:radio[name=insaqlim][value=0]').attr('checked', true)" . $desab . ";";
			echo "$('input:radio[name=insaqlim][value=1]')" . $desab . ";";
		}
		
		if ($inaleblq == '1') {
			echo "$('input:radio[name=inaleblq][value=1]').attr('checked', true)" . $desab . ";";
			echo "$('input:radio[name=inaleblq][value=0]')" . $desab . ";";
		} else {
			echo "$('input:radio[name=inaleblq][value=0]').attr('checked', true)" . $desab . ";";
			echo "$('input:radio[name=inaleblq][value=1]')" . $desab . ";";
		}

		if ($flmstted == 'yes') {
			echo "$('input:radio[name=flmstted][value=1]').attr('checked', true)" . $desab . ";";
			echo "$('input:radio[name=flmstted][value=0]')" . $desab . ";";
		} else {
			echo "$('input:radio[name=flmstted][value=0]').attr('checked', true)" . $desab . ";";
			echo "$('input:radio[name=flmstted][value=1]')" . $desab . ";";
		}
		
		if ($flnvfted == 'yes') {
			echo "$('input:radio[name=flnvfted][value=1]').attr('checked', true)" . $desab . ";";
			echo "$('input:radio[name=flnvfted][value=0]')" . $desab . ";";
		} else {
			echo "$('input:radio[name=flnvfted][value=0]').attr('checked', true)" . $desab . ";";
			echo "$('input:radio[name=flnvfted][value=1]')" . $desab . ";";
		}
		
		if ($flmobted == 'yes') {
			echo "$('input:radio[name=flmobted][value=1]').attr('checked', true)" . $desab . ";";
			echo "$('input:radio[name=flmobted][value=0]')" . $desab . ";";
		} else {
			echo "$('input:radio[name=flmobted][value=0]').attr('checked', true)" . $desab . ";";
			echo "$('input:radio[name=flmobted][value=1]')" . $desab . ";";
		}
		
		if ($flmntage == 'yes') {
			echo "$('input:radio[name=flmntage][value=1]').attr('checked', true)" . $desab . ";";
			echo "$('input:radio[name=flmntage][value=0]')" . $desab . ";";
		} else {
			echo "$('input:radio[name=flmntage][value=0]').attr('checked', true)" . $desab . ";";
			echo "$('input:radio[name=flmntage][value=1]')" . $desab . ";";
		}
		
        // Chama o carregamento dos estados
        echo 'carregaEstados();';
        }
        //PLD
        if($cddopcao == 'AP' || $cddopcao == 'CP' || $cddopcao == 'C2'){
        	
			echo "$('#qtrendadiariopf','#frmparmon').val('".($qtrendadiariopf)."')".$desab.";";
			echo "$('#qtrendadiariopj','#frmparmon').val('".($qtrendadiariopj)."')".$desab.";";			
			echo "$('#vlcreditodiariopf','#frmparmon').val('".($vlcreditodiariopf)."')".$desab.";";	        
			echo "$('#vlcreditodiariopj','#frmparmon').val('".($vlcreditodiariopj)."')".$desab.";";			
			echo "$('#qtrendamensalpf','#frmparmon').val('".($qtrendamensalpf)."')".$desab.";";
			echo "$('#qtrendamensalpj','#frmparmon').val('".($qtrendamensalpj)."')".$desab.";";
			echo "$('#vlprovpagtoespecie','#frmparmon').val('".($vlprovpagtoespecie)."')".$desab.";";
			echo "$('#vlcreditomensalpf','#frmparmon').val('".($vlcreditomensalpf)."')".$desab.";";
			echo "$('#vlcreditomensalpj','#frmparmon').val('".($vlcreditomensalpj)."')".$desab.";";
			echo "$('#vllimitesaque','#frmparmon').val('".($vllimitesaque)."')".$desab.";";
			echo "$('#inrendazerada','#frmparmon').attr('checked',".(($inrendazerada==1)?'true':'false').")".$desab.";";		
			echo "$('#vllimitedeposito','#frmparmon').val('".($vllimitedeposito)."')".$desab.";";
			echo "$('#vllimitepagamento','#frmparmon').val('".($vllimitepagamento)."')".$desab.";";
			echo "$('#vlprovisaoemail','#frmparmon').val('".($vlprovisaoemail)."')".$desab.";";
			echo "$('#vlprovisaosaque','#frmparmon').val('".($vlprovisaosaque)."')".$desab.";";			
			echo "$('#vlmonpagto','#frmparmon').val('".($vlmonpagto)."')".$desab.";";			
			echo "$('#qtdiasprovisao','#frmparmon').val('".($qtdiasprovisao)."')".$desab.";";			
			echo "$('#hrlimiteprovisao','#frmparmon').val('".($hrlimiteprovisao)."')".$desab.";";
			echo "$('#qtdiasprovisaocancelamento','#frmparmon').val('".($qtdiasprovisaocancelamento)."')".$desab.";";			
			echo "$('#inliberasaque','#frmparmon').attr('checked',".(($inliberasaque==1)?'true':'false').")".$desab.";";
			echo "$('#inliberaprovisaosaque','#frmparmon').attr('checked',".(($inliberaprovisaosaque==1)?'true':'false').")".$desab.";";
			echo "$('#inalteraprovisaopresencial','#frmparmon').attr('checked',".(($inalteraprovisaopresencial==1)?'true':'false').")".$desab.";";
			echo "$('#inverificasaldo','#frmparmon').attr('checked',".(($inverificasaldo==1)?'true':'false').")".$desab.";";
			echo "$('#dsdeemail','#frmparmon').val('".($dsdeemail)."')".$desab.";";
			echo "$('#dsdemailseg','#frmparmon').val('".($dsdemailseg)."')".$desab.";";				
        }        
		
		echo $btcon;
		echo $focus;
		
		if(count($coops) > 0){
		?>
			$('#divCoptel','#frmparmon').show();
			$('#dsdeemail','#frmparmon').desabilitaCampo();
			lstCooperativas = new Array(); // Inicializar lista de cooperativas
			<? 
			for ($i = 0; $i < count($coops); $i++){
				$cdcooper = $coops[$i]->codcoope;
				$nmrescop = $coops[$i]->nmrescop;	
				?>
				objCooper = new Object();
				objCooper.cdcooper = "<?php echo $cdcooper; ?>";
				objCooper.nmrescop = "<?php echo $nmrescop; ?>";
				lstCooperativas[<?php echo $i; ?>] = objCooper;
				<?
			}
			echo 'carregaCooperativas("'.count($coops).'");';
			
			if($cddopcao == "C" or $cddopcao == "C1" or $cddopcao == 'CP' or $cddopcao == 'C2'){
				?>
				$('#dsidpara','#frmparmon').prop('multiple',false).css({'height':''}).val('<?php echo $cdcoptel; ?>').focus();
				$('#spanInfo','#frmparmon').hide();
				<?php
			}elseif($cddopcao == "A" || $cddopcao=="A1" || $cddopcao == 'AP' || $cddopcao =='A2' ){
				?>
				if('<?php echo $cdcoptel; ?>' == 'A' || '<?php echo $cdcoptel; ?>' == 'A1'){
				$('#vlinimon','#frmparmon').val('0,00');
				$('#vllmonip','#frmparmon').val('0,00');
				$('#vlinisaq','#frmparmon').val('0,00');
				$('#vlinitrf','#frmparmon').val('0,00');
				$('#vlsaqind','#frmparmon').val('0,00');
                $('#vlmnlmtd','#frmparmon').val('0,00');
                $('#vlinited','#frmparmon').val('0,00');
				$('input:radio[name=insaqlim]').attr('checked', false);
				$('input:radio[name=inaleblq]').attr('checked', false);
                $('input:radio[name=flmstted]').attr('checked', false);
				$('input:radio[name=flnvfted]').attr('checked', false);
				$('input:radio[name=flmobted]').attr('checked', false);
				$('input:radio[name=flmntage]').attr('checked', false);
				}
				$('#dsidpara','#frmparmon').prop('multiple',true).css({'height':'140px'}).val('0');
				$('#spanInfo','#frmparmon').show();
				<?php
			}
		}
		
		echo "hideMsgAguardo();";
		
	}else if ($cddopcao == "A1" || $cddopcao == "A2"){
		
		echo "showError('inform','Par&acirc;metros de monitora&ccedil;&atilde;o alterados com sucesso!','Alerta - Ayllos','estadoInicial();hideMsgAguardo();');";
		exit();
	}
?>