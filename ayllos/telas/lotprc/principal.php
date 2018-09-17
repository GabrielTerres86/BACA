<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 07/05/2013
 * OBJETIVO     : Rotianas da tela LOTPRC
 * --------------
 * ALTERAÇÕES   : 29/10/2013 - Adicionado opcao "R" e ajustes de rotina. (Jorge)
				  
				  19/12/2013 - Alterado coluna da tabela do form frmListAvali
							   de "CPF/CGC" para "CPF/CNPJ". (Reinert)

                  30/07/2018 - SCTASK0021664 Inclusão do campo vlperfin (percentual financiado) (Carlos)
 * -------------- 
 */ 	
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	

	// Recebe o POST
	$cddopcao = (isset($_POST['cddopcao']))      ? $_POST['cddopcao'] : '' ;
	$nrdconta = (isset($_POST['nrdconta'])) 	 ? $_POST['nrdconta'] : 0  ;
	$nrdolote = (isset($_POST['nrdolote']))      ? $_POST['nrdolote'] : 0  ;
	$vlprocap = (isset($_POST['vlprocap']))      ? $_POST['vlprocap'] : 0  ;
	$dtvencnd = (validaData($_POST['dtvencnd'])) ? $_POST['dtvencnd'] : '' ;
	$cdmunben = (isset($_POST['cdmunben'])) 	 ? $_POST['cdmunben'] : 0  ;
	$cdgenben = (isset($_POST['cdgenben'])) 	 ? $_POST['cdgenben'] : 0  ;
	$cdporben = (isset($_POST['cdporben'])) 	 ? $_POST['cdporben'] : 0  ;
	$cdsetben = (isset($_POST['cdsetben'])) 	 ? $_POST['cdsetben'] : 0  ;
	$dtcndfed = (validaData($_POST['dtcndfed'])) ? $_POST['dtcndfed'] : '' ;
	$dtcndfgt = (validaData($_POST['dtcndfgt'])) ? $_POST['dtcndfgt'] : '' ;
	$dtcndest = (validaData($_POST['dtcndest'])) ? $_POST['dtcndest'] : '' ;
	$dtcontrt = (validaData($_POST['dtcontrt'])) ? $_POST['dtcontrt'] : '' ;
	$dtpricar = (validaData($_POST['dtpricar'])) ? $_POST['dtpricar'] : '' ;
	$dtfincar = (validaData($_POST['dtfincar'])) ? $_POST['dtfincar'] : '' ;
	$dtpriamo = (validaData($_POST['dtpriamo'])) ? $_POST['dtpriamo'] : '' ;
	$dtultamo = (validaData($_POST['dtultamo'])) ? $_POST['dtultamo'] : '' ;
	$cdmunbce = (isset($_POST['cdmunbce'])) 	 ? $_POST['cdmunbce'] : 0  ;
	$cdsetpro = (isset($_POST['cdsetpro'])) 	 ? $_POST['cdsetpro'] : 0  ;
	$flgvalid = (isset($_POST['flgvalid'])) 	 ? $_POST['flgvalid'] : false  ;
	$lstavali = (isset($_POST['lstavali']))		 ? $_POST['lstavali'] : '' ;
	$flgdload = (isset($_POST['flgdload'])) 	 ? $_POST['flgdload'] : false  ;
    $vlperfin = (isset($_POST['vlperfin']))      ? $_POST['vlperfin'] : 80  ;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	switch( $cddopcao ) {
		case 'N':  $procedure = 'abrir_lote'; 		    break;
		case 'I':  $procedure = $flgvalid ? 'verificar_conta_lote' : 'incluir_conta_lote'; break;
		case 'C':  $procedure = 'consultar_conta_lote'; break;
		case 'A':  $procedure = $flgvalid ? 'consultar_conta_lote' : 'alterar_conta_lote'; break;
		case 'W':  $procedure = $flgdload ? 'consultar_lote' : 'alterar_lote';  break;
		case 'E':  $procedure = 'excluir_conta_lote';   break;
		case 'F':  $procedure = 'fechar_lote'; 		    break;
		case 'L':  $procedure = 'reabrir_lote'; 		break;
		case 'Z':  $procedure = 'finalizar_lote'; 	    break;
		case 'G':  $procedure = 'gerar_arq_enc_brde';   break;
		case 'T':  $procedure = 'gerar_arq_fin_brde';   break;
		case 'R':  $procedure = 'relatorio_lote'; 	    break;
		default :  $procedure = ''; 					break;
	}
	
	if ($procedure == ''){
		exibirErro('error','Opção inválida!','Alerta - Ayllos','',false);
	}
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0156.p</Bo>';
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
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<nrdolote>'.$nrdolote.'</nrdolote>';
	$xml .= '		<vlprocap>'.$vlprocap.'</vlprocap>';
	$xml .= '		<dtvencnd>'.$dtvencnd.'</dtvencnd>';
	$xml .= '		<cdmunben>'.$cdmunben.'</cdmunben>';
	$xml .= '		<cdgenben>'.$cdgenben.'</cdgenben>';
	$xml .= '		<cdporben>'.$cdporben.'</cdporben>';
	$xml .= '		<cdsetben>'.$cdsetben.'</cdsetben>';
	$xml .= '		<dtcndfed>'.$dtcndfed.'</dtcndfed>';
	$xml .= '		<dtcndfgt>'.$dtcndfgt.'</dtcndfgt>';
	$xml .= '		<dtcndest>'.$dtcndest.'</dtcndest>';
	$xml .= '		<dtcontrt>'.$dtcontrt.'</dtcontrt>';
	$xml .= '		<dtpricar>'.$dtpricar.'</dtpricar>';
	$xml .= '		<dtfincar>'.$dtfincar.'</dtfincar>';
	$xml .= '		<dtpriamo>'.$dtpriamo.'</dtpriamo>';
	$xml .= '		<dtultamo>'.$dtultamo.'</dtultamo>';
	$xml .= '		<cdmunbce>'.$cdmunbce.'</cdmunbce>';
	$xml .= '		<cdsetpro>'.$cdsetpro.'</cdsetpro>';
	$xml .= '		<lstavali>'.$lstavali.'</lstavali>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
    $xml .= '       <vlperfin>'.$vlperfin.'</vlperfin>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);
	
	$flprocok = $xmlObjeto->roottag->tags[0]->attributes['FLPROCOK'];
	$nmarqerr = $xmlObjeto->roottag->tags[0]->attributes['NMARQERR'];
	$inpessoa = $xmlObjeto->roottag->tags[0]->attributes['INPESSOA'];
	
	
	if(trim($nmarqerr) <> ""){
		$msgErro = "Erro ao tentar fechar lote ".$nrdolote.". Foi gerado um arquivo de erros em <br>".$nmarqerr.".";
		$retornoAposErro = "$('#btVoltar','#divBotoes').show();$('#btnContinuar','#divBotoes').show();$('#cddopcao','#frmCab').habilitaCampo();hideMsgAguardo();";
		?> 
			showError('error','<?php echo $msgErro; ?>','<?php echo utf8_decode("Alerta - Ayllos"); ?>',"<?php echo $retornoAposErro; ?>");
		<?php
		exit();
	}
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		$retornoAposErro = "$('#btVoltar','#divBotoes').show();$('#btnContinuar','#divBotoes').show();"; 
		
		if (!empty($nmdcampo)) { 
			$nmdoform = ($nmdcampo == "nrdconta" || $nmdcampo == "nrdolote") ? "frmOpcao" : "frmContaLote";
			$retornoAposErro .= "$('#cddopcao','#frmCab').val('".$cddopcao."');focaCampoErro('".$nmdcampo."','".$nmdoform."');"; 
		}else{
			$retornoAposErro .= "$('#cddopcao','#frmCab').habilitaCampo();";
		}
		
		$retornoAposErro .= "hideMsgAguardo();";
		
		$msgErro = "<div style=\"text-align:left;\">";
		$taberros = $xmlObjeto->roottag->tags[0]->tags;
		for($i=0;$i<count($taberros);$i++){
			if($i==0){
				$msgErro .= $taberros[$i]->tags[4]->cdata;
			}else{
				$msgErro .= "<br>".$taberros[$i]->tags[4]->cdata;
			}
		}	
		$msgErro .= "</div>";
		?> 
			showError('error','<?php echo $msgErro; ?>','<?php echo utf8_decode("Alerta - Ayllos"); ?>',"<?php echo $retornoAposErro; ?>");
		<?php
		exit();
	}
	
	if(strtoupper($xmlObjeto->roottag->tags[0]->name) == 'LOTES')  {
		$lotes = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	}
	
	if(strtoupper($xmlObjeto->roottag->tags[1]->name) == 'CONTASLOTE') {
		$contaslote = $xmlObjeto->roottag->tags[1]->tags[0]->tags;
	}	
	
	if(strtoupper($xmlObjeto->roottag->tags[0]->name) == 'AVALISTAS')  {
		$avalistas = $xmlObjeto->roottag->tags[0]->tags;
		echo "$('#divAvalista').fadeTo(0,0.1);";
		$tabela = "";
		
		if (count($avalistas) > 0) {
				
			$tabela .= "<form id=\'frmListAvali\' class=\'formulario\' onSubmit=\'return false;\' >";
			$tabela .= "<fieldset>";
			$tabela .= "<legend>Avalistas</legend>";
			$tabela .= "<br />";
			$tabela .= "<div class=\'divRegistros\'>";
			$tabela .= 	"<table WIDTH=\'100%\'>";
			$tabela .=		"<thead>";
			$tabela .=			"<tr>";
			$tabela .=				"<th align=\'CENTER\'>&nbsp;</th>";
			$tabela .=				"<th align=\'CENTER\'>CPF/CNPJ</th>";
			$tabela .=				"<th align=\'CENTER\'>CONTA/DV</th>";
			$tabela .=				"<th align=\'CENTER\'>NOME</th>";
			$tabela .=			"</tr>";
			$tabela .=		"</thead>";
			$tabela .=		"<tbody>";
			for ($i = 0; $i < count($avalistas); $i++) {
				$nrcpfcgc = getByTagName($avalistas[$i]->tags,'nrcpfcgc');
				$nrdctato = getByTagName($avalistas[$i]->tags,'nrdctato');
				$nmdavali = getByTagName($avalistas[$i]->tags,'nmdavali');
				
				$checked  = getByTagName($avalistas[$i]->tags,'flgcheck');
				$checked  = ($checked  == "yes") ? "checked=\'checked\'"   : "";
				$disabled = ($cddopcao == "C")   ? "disabled=\'disabled\'" : "";
				
				$tabela .=		"<tr>";
				$tabela .=			"<td style=\'text-align:center;\'>";
				$tabela .=			    "<input type=\'checkbox\' id=\'chkava".$i."\' name=\'chkavali[]\' value=\'".$nrcpfcgc."\' ".$checked." ".$disabled." />";
				$tabela .=			"</td>";
				$tabela .=			"<td align=\'center\'>";
				$tabela .=				 $nrcpfcgc;
				$tabela .=			"</td>";
				$tabela .=			"<td align=\'center\'>";
				$tabela .=				 formataContaDV($nrdctato);
				$tabela .=			"</td>";
				$tabela .=			"<td align=\'center\'>";
				$tabela .=				 $nmdavali;
				$tabela .=			"</td>";
				$tabela .=		"</tr>";
				
			}
			
			$tabela .=		"</tbody>";
			$tabela .=	"</table>";
			$tabela .= "</div>";
			$tabela .= "</fieldset>";
			$tabela .= "</form>";
			
			echo "$('#divAvalista').html('".$tabela."');"; 
			echo "formataTabela();";
			echo "removeOpacidade('divAvalista');";
			
		}
		
	}
	
	$nwdolote = $xmlObjeto->roottag->tags[0]->attributes['NRDOLOTE'];
	if($nwdolote != ''){
		$nrdolote = $nwdolote;
	}
	
	if($cddopcao == 'N'){
	?>
		showError('inform','<?php echo utf8_decode("Lote nº ".$nrdolote." criado com sucesso!"); ?>','<?php echo utf8_decode("Informação - Ayllos"); ?>',"estadoInicial();");
	<?php 
	}else if(($cddopcao == 'I' && $flgvalid) || $cddopcao == "C" || ($cddopcao == "A" && $flgvalid)){
	?>
		$("#nrdconta","#frmOpcao").desabilitaCampo();
		$("#nrdolote","#frmOpcao").desabilitaCampo();
		$("#frmContaLote").fadeTo(0,0.1);
		$("#vlprocap","#frmContaLote").focus();
		removeOpacidade("frmContaLote");
		<?php
		
		if($cddopcao == 'C' || $cddopcao == 'A'){
			if($cddopcao == 'C'){ ?>
				$('#btvoltar','#divBotoes').focus();
			<?php
			}
			$desabilita = $cddopcao == 'C' ? ".desabilitaCampo()" : "";
			if(count($contaslote) > 0){
				for($i=0;$i<(count($contaslote));$i++){
					$valorcampo = trim($contaslote[$i]->cdata);
					if(trim(strtolower($contaslote[$i]->name)) == "vlprocap"){
						$valorcampo = formataMoeda($valorcampo);
					}
					echo '$("#'.trim(strtolower($contaslote[$i]->name)).'","#frmContaLote").val("'.$valorcampo.'")'.$desabilita.';';
				}
			}
		}
		
		if($inpessoa == "1" || $cddopcao == 'C'){ ?>
			$("#dtcndfgt","#frmContaLote").desabilitaCampo();
			$("#dtcndest","#frmContaLote").desabilitaCampo();
		<?php
		}else{ ?>
			$("#dtcndfgt","#frmContaLote").habilitaCampo();
			$("#dtcndest","#frmContaLote").habilitaCampo();
		<?php
		}
		
	}else if($cddopcao == 'I'){
	?>
		showError('inform','<?php echo utf8_decode("Conta/DV ".formataContaDV($nrdconta)." Incluída no Lote nº ".$nrdolote." com sucesso!"); ?>','<?php echo utf8_decode("Informação - Ayllos"); ?>',"btnVoltar();");
	<?php
	}else if($cddopcao == 'A'){
	?>
		showError('inform','<?php echo utf8_decode("Conta/DV ".formataContaDV($nrdconta)." Alterada no Lote nº ".$nrdolote." com sucesso!"); ?>','<?php echo utf8_decode("Informação - Ayllos"); ?>',"btnVoltar();");
	<?php
	}else if($cddopcao == 'E'){
	?>
		showError('inform','<?php echo utf8_decode("Conta/DV ".formataContaDV($nrdconta)." Excluída do Lote nº ".$nrdolote." com sucesso!"); ?>','<?php echo utf8_decode("Informação - Ayllos"); ?>',"estadoInicial();");
	<?php
	}else if($cddopcao == 'W' && $flgdload){
	?>
		$("#nrdconta","#frmOpcao").desabilitaCampo();
		$("#nrdolote","#frmOpcao").desabilitaCampo();
		$("#frmCadLote").fadeTo(0,0.1);
		$("#dtcontrt","#frmCadLote").focus();
		removeOpacidade("frmCadLote");
		<?php
		
		if(count($lotes) > 0){
			for($i=0;$i<(count($lotes));$i++){
				$valorcampo = trim($lotes[$i]->cdata);
				echo '$("#'.trim(strtolower($lotes[$i]->name)).'","#frmCadLote").val("'.$valorcampo.'");';
			}
		}
	}else if($cddopcao == 'W'){
	?>
		showError('inform','<?php echo utf8_decode("Informações do lote salvas com sucesso!"); ?>','<?php echo utf8_decode("Informação - Ayllos"); ?>',"estadoInicial();");
	<?php
	}else if($cddopcao == 'F'){
	?>
		showError('inform','<?php echo utf8_decode("Lote nº ".$nrdolote." Fechado com sucesso!"); ?>','<?php echo utf8_decode("Informação - Ayllos"); ?>',"estadoInicial();");
	<?php
	}else if($cddopcao == 'L'){
	?>
		showError('inform','<?php echo utf8_decode("Lote nº ".$nrdolote." Reaberto com sucesso!"); ?>','<?php echo utf8_decode("Informação - Ayllos"); ?>',"estadoInicial();");
	<?php
	}else if($cddopcao == 'Z'){
	?>
		showError('inform','<?php echo utf8_decode("Lote nº ".$nrdolote." Finalizado com sucesso!"); ?>','<?php echo utf8_decode("Informação - Ayllos"); ?>',"estadoInicial();");
	<?php
	}else if($cddopcao == 'G'){
		$nmarquiv = $xmlObjeto->roottag->tags[0]->attributes['NMARQUIV'];
	?>
		showError('inform','<?php echo utf8_decode("Arquivo do Lote nº ".$nrdolote." gerado com sucesso no diretório<br>".$nmarquiv); ?>','<?php echo utf8_decode("Informação - Ayllos"); ?>',"estadoInicial();");
	<?php
	}else if($cddopcao == 'R'){
		$nmarquiv = $xmlObjeto->roottag->tags[0]->attributes['NMARQIMP'];
		$nmarqpdf = $xmlObjeto->roottag->tags[0]->attributes['NMARQPDF'];
	?>
		showConfirmacao('<?php echo utf8_decode("Relatório do Lote nº ".$nrdolote." gerado com sucesso!")."<br>Deseja visualizar?"; ?>','<?php echo utf8_decode("Confirmação - Ayllos"); ?>','Gera_Impressao("<?php echo $nmarqpdf; ?>");','estadoInicial();','sim.gif','nao.gif');
	<?php
	}
?>

