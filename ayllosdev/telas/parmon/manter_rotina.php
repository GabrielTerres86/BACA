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
		default  : { exibirErro('atencao','Op&ccedil;&atilde;o Invalida!','Alerta - Ayllos','',false); }
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$realopcao)) <> '') {		
		exibirErro('atencao',$msgError,'Alerta - Ayllos','',false);
	}
	
	if($cddopcao == "A1"){
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
	
	$xmlObj = simplexml_load_string($xmlResult);
		
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
	
	$coops    = $xmlObj->CRAPCOP->Registro;
	
	if ($cddopcao == "C" or $cddopcao == "C1" or $cddopcao == "A"){
		
		$desab = ($cddopcao == "C" or $cddopcao == "C1") ? ".desabilitaCampo()" : ".habilitaCampo()";
		$btcon = ($cddopcao == "C" or $cddopcao == "C1") ? "$('#btSalvar').hide();" : "";
		$focus = ($cddopcao == "A") ? "$('#vlinimon','#frmparmon').focus();" : "$('#btVoltar','#divBotoes').focus();";
		
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
		
		echo $btcon;
		echo $focus;
		
		if(count($coops) > 0){
		?>
			$('#divCoptel','#frmparmon').show();
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
			
			if($cddopcao == "C" or $cddopcao == "C1"){
				?>
				$('#dsidpara','#frmparmon').prop('multiple',false).css({'height':''}).val('<?php echo $cdcoptel; ?>').focus();
				$('#spanInfo','#frmparmon').hide();
				<?php
			}else{
				?>
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
				$('#dsidpara','#frmparmon').prop('multiple',true).css({'height':'140px'}).val('0');
				$('#spanInfo','#frmparmon').show();
				<?php
			}
		}
		
		echo "hideMsgAguardo();";
		
	}else if ($cddopcao == "A1"){
		
		echo "showError('inform','Par&acirc;metros de monitora&ccedil;&atilde;o alterados com sucesso!','Alerta - Ayllos','estadoInicial();hideMsgAguardo();');";
		exit();
	}
?>