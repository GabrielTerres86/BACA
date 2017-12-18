<? 
/*!
 * FONTE        : valida_dados_gerais.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 10/03/2011 
 * OBJETIVO     : Verifica dados da proposta
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [05/03/2012] Tiago   : Incluido tpemprst.
 * 002: [09/04/2012] Gabriel : Incluir dtlibera.
 * 003: [28/11/2012] Adriano : Ajustes referente ao projeto GE (Adriano).
 * 004: [05/02/2014] Jorge   : Adicionado campo percetop.
 * 005: [06/10/2014] Lucas R. : Retirado validação do percetop, pois o campo cet estara bloqueado.
 * 006: [18/11/2014] Jaison: Inclusao do parametro nrcpfope.
 * 007: [29/06/2015] James: Ajuste para carregar o Nivel Risco quando for refinanciamento
 * 008: [10/07/2015] Reinert: Adicionado parametro cdmodali
 * 009: [11/09/2015] James: Ajuste para carregar a data de liberação		 
 * 010: [15/12/2017] Inserção do campo idcobope. PRJ404 (Lombardi)
 */
?>
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : ''; 
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$cdageass = (isset($_POST['cdageass'])) ? $_POST['cdageass'] : ''; 
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : ''; 
	$cdlcremp = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : ''; 
	$qtpreemp = (isset($_POST['qtpreemp'])) ? $_POST['qtpreemp'] : ''; 
	$dsctrliq = (isset($_POST['dsctrliq'])) ? $_POST['dsctrliq'] : ''; 
	$vlmaxutl = (isset($_POST['vlmaxutl'])) ? $_POST['vlmaxutl'] : ''; 
	$vlmaxleg = (isset($_POST['vlmaxleg'])) ? $_POST['vlmaxleg'] : ''; 
	$vlcnsscr = (isset($_POST['vlcnsscr'])) ? $_POST['vlcnsscr'] : ''; 
	$vlemprst = (isset($_POST['vlemprst'])) ? $_POST['vlemprst'] : ''; 
	$dtdpagto = (isset($_POST['dtdpagto'])) ? $_POST['dtdpagto'] : ''; 
	$inconfir = (isset($_POST['inconfir'])) ? $_POST['inconfir'] : ''; 
	$tpaltera = (isset($_POST['tpaltera'])) ? $_POST['tpaltera'] : ''; 
	$cdempres = (isset($_POST['cdempres'])) ? $_POST['cdempres'] : ''; 
	$flgpagto = (isset($_POST['flgpagto'])) ? $_POST['flgpagto'] : ''; 
	$dtdpagt2 = (isset($_POST['dtdpagt2'])) ? $_POST['dtdpagt2'] : ''; 
	$ddmesnov = (isset($_POST['ddmesnov'])) ? $_POST['ddmesnov'] : ''; 
	$cdfinemp = (isset($_POST['cdfinemp'])) ? $_POST['cdfinemp'] : ''; 
	$qtdialib = (isset($_POST['qtdialib'])) ? $_POST['qtdialib'] : '';
	$inmatric = (isset($_POST['inmatric'])) ? $_POST['inmatric'] : '';
	$tpemprst = (isset($_POST['tpemprst'])) ? $_POST['tpemprst'] : '';
	$dtlibera = (isset($_POST['dtlibera'])) ? $_POST['dtlibera'] : '';
	$idcobope = (isset($_POST['idcobope'])) ? $_POST['idcobope'] : '';
	$inconfi2 = (isset($_POST['inconfi2'])) ? $_POST['inconfi2'] : '';
	$percetop = (isset($_POST['percetop'])) ? $_POST['percetop'] : 0;
	$cdmodali = (isset($_POST['cdmodali'])) ? $_POST['cdmodali'] : '0';
	$cddopcao = 'A';
	
	if( $operacao == 'TI' ){ $cddopcao = 'I'; }
	else if( $operacao == 'I_INICIO' ){ $cddopcao = 'I'; }
	
	/* Sempre quando o emprestimo for PP, vamos atualizar a data de liberacao do emprestimo para a data atual. Projeto do Estorno 215 */
	if ($tpemprst == 1){
		$dtlibera = $glbvars["dtmvtolt"];
	}
						
	// Monta o xml de requisição
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0002.p</Bo>";
	$xml .= "		<Proc>valida-dados-gerais</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";	
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xml .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";	
	$xml .= "		<inproces>".$glbvars["inproces"]."</inproces>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<cdageass>".$cdageass."</cdageass>";
	$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "		<cdlcremp>".$cdlcremp."</cdlcremp>";
	$xml .= "		<qtpreemp>".$qtpreemp."</qtpreemp>";
	$xml .= "		<dsctrliq>".$dsctrliq."</dsctrliq>";
	$xml .= "		<vlmaxutl>".$vlmaxutl."</vlmaxutl>";
	$xml .= "		<vlmaxleg>".$vlmaxleg."</vlmaxleg>";
	$xml .= "		<vlcnsscr>".$vlcnsscr."</vlcnsscr>";
	$xml .= "		<vlemprst>".$vlemprst."</vlemprst>";
	$xml .= "		<dtdpagto>".$dtdpagto."</dtdpagto>";
	$xml .= "		<inconfir>".$inconfir."</inconfir>";
	$xml .= "		<tpaltera>".$tpaltera."</tpaltera>";
	$xml .= "		<cdempres>".$cdempres."</cdempres>";
	$xml .= "		<flgpagto>".$flgpagto."</flgpagto>";
	$xml .= "		<dtdpagt2>".$dtdpagt2."</dtdpagt2>";
	$xml .= "		<ddmesnov>".$ddmesnov."</ddmesnov>";
	$xml .= "		<cdfinemp>".$cdfinemp."</cdfinemp>";
	$xml .= "		<qtdialib>".$qtdialib."</qtdialib>";
	$xml .= "		<inmatric>".$inmatric."</inmatric>";
	$xml .= "		<tpemprst>".$tpemprst."</tpemprst>";
	$xml .= "		<dtlibera>".$dtlibera."</dtlibera>";
	$xml .= "		<inconfi2>".$inconfi2."</inconfi2>";
    $xml .= "		<nrcpfope>0</nrcpfope>";
	$xml .= "		<cdmodali>".$cdmodali."</cdmodali>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
	
		$mensagGe = $xmlObj->roottag->tags[1]->tags;
		$inconfge = $xmlObj->roottag->tags[1]->tags[0]->tags[0]->cdata;
		$dscmsgge = $xmlObj->roottag->tags[1]->tags[0]->tags[1]->cdata;
		$grupo    = $xmlObj->roottag->tags[2]->tags;
		
		/*Se a conta em questão pertence a um grupo economico e o valor legal for excedido então, será mostrado 
		  todas as contas deste grupo.*/
		if(count($grupo) > 0 && $inconfge == 3){ ?>	
		
			strHTML = '';
			strHTML2 = '';
						
			strHTML2 += '<form name="frmGrupoEconomico" id="frmGrupoEconomico" class="formulario">';
			strHTML2 +=		'<br />';
			strHTML2 +=		'Conta pertence a grupo econ&ocirc;mico.';
			strHTML2 +=		'<br />';
			strHTML2 +=		'Valor ultrapassa limite legal permitido.';
			strHTML2 +=		'<br />';
			strHTML2 +=		'Verifique endividamento total das contas.';
			strHTML2 += '</form>';
			strHTML  += '<br style="clear:both" />';
			strHTML  += '<br style="clear:both" />';
			strHTML  += '<div class="divRegistros">';
			strHTML  +=	'<table>';
			strHTML  +=		'<thead>';
			strHTML  +=			'<tr>';
			strHTML  +=				'<th>Contas Relacionadas</th>';
			strHTML  +=			'</tr>';
			strHTML  +=		'</thead>';
			strHTML  +=		'<tbody>';
		
			
			<?php 
			for ($i = 0; $i < count($grupo); $i++) { ?>
					
				strHTML +=				'<tr>';
				strHTML +=					'<td><span><?php echo $grupo[$i]->tags[2]->cdata;?></span>';
				strHTML +=							'<?php echo formataContaDV($grupo[$i]->tags[2]->cdata);?>';
				strHTML +=					'</td>';
				strHTML +=				'</tr>';
						
			<?php
			}
			?>
			
			strHTML +=		'</tbody>';
			strHTML +=	'</table>';
						
			dsmetodo = 'showError("error","<?echo $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;?>","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';
			inconfir = 1;
			inconfi2 = 30;
			showError("inform","<?echo $dscmsgge;?>","Alerta - Ayllos","mostraMsgsGrupoEconomico();formataGrupoEconomico();");
		
			<?
			exit();
			
		}elseif($inconfge == 3){?>
			hideMsgAguardo();
			inconfir = 1;
			inconfi2 = 30;
			showError("inform","<? echo $dscmsgge;?>","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();showError('error','<?echo $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;?>','Alerta - Ayllos','blockBackground(parseInt($(\\'#divRotina\\').css(\\'z-index\\')))');");
			<?
			exit();
		
		}else{
			echo 'inconfir = 1;';
			echo 'inconfi2 = 30;';
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
		
		}
		
	}
	
	$mensagem = $xmlObj->roottag->tags[0]->tags[0]->tags;
	
	$dsmesage = trim($xmlObj->roottag->tags[0]->attributes['DSMESAGE']);
	$vlutiliz = trim($xmlObj->roottag->tags[0]->attributes['VLUTILIZ']);
	$vlpreemp = trim($xmlObj->roottag->tags[0]->attributes['VLPREEMP']);
	$dslcremp = trim($xmlObj->roottag->tags[0]->attributes['DSLCREMP']);
	$dsfinemp = trim($xmlObj->roottag->tags[0]->attributes['DSFINEMP']);
	$tplcremp = trim($xmlObj->roottag->tags[0]->attributes['TPLCREMP']);
	$flgpagto = trim($xmlObj->roottag->tags[0]->attributes['FLGPAGTO']);
	$dtdpagto = trim($xmlObj->roottag->tags[0]->attributes['DTDPAGTO']);
	$nivrisco = trim($xmlObj->roottag->tags[0]->attributes['NIVRISCO']);
	$dsmensag = trim( getByTagName($mensagem,'dsmensag') );
	$inconfir = trim( getByTagName($mensagem,'inconfir') );
	
	if($inconfir == 31){ 
		echo "inconfi2 = '".$inconfir."';"; 
	}else{
		echo "inconfir = '".$inconfir."';";
	}
		
	echo "vlutiliz = '".$vlutiliz."';";			
	echo "dsmensag = '".$dsmensag."';";
	echo "dsmesage = '".$dsmesage."';";
							
	echo "arrayProposta['vlpreemp'] = '".$vlpreemp."';";
	echo "arrayProposta['dslcremp'] = '".$dslcremp."';";
	echo "arrayProposta['dsfinemp'] = '".$dsfinemp."';";
	echo "arrayProposta['tplcremp'] = '".$tplcremp."';";
	echo "arrayProposta['flgpagto'] = '".$flgpagto."';";
	echo "arrayProposta['dtdpagto'] = '".$dtdpagto."';";	
	echo "arrayProposta['nivrisco'] = '".$nivrisco."';";
	echo "arrayProposta['dtlibera'] = '".$dtlibera."';";	
	echo "arrayProposta['idcobope'] = '".$idcobope."';";	
	echo "aDadosPropostaFinalidade['dsnivris'] = arrayProposta['nivrisco'];";
	
	echo "$('#vlpreemp','#frmNovaProp').val('".$vlpreemp."');";
	echo "$('#vlpreemp','#frmNovaProp').trigger('blur');";
	echo "$('#dslcremp','#frmNovaProp').val('".$dslcremp."');";
	echo "$('#dsfinemp','#frmNovaProp').val('".$dsfinemp."');";
	echo "$('#flgpagto','#frmNovaProp').val('".$flgpagto."');";
	echo "$('#dtdpagto','#frmNovaProp').val('".$dtdpagto."');";
	echo "$('#nivrisco','#frmNovaProp').val('".$nivrisco."');";
	echo "$('#dtlibera','#frmNovaProp').val('".$dtlibera."');";
	echo "$('#idcobope','#frmNovaProp').val('".$idcobope."');";
?>