<? 
/*!
 * FONTE        : titulos_limite_formulario.php
 * CRIAÇÃO      : David
 * DATA CRIAÇÃO : Junho/2007
 * OBJETIVO     : Carregar formulário de dados para gerenciar limite
 * --------------
 * ALTERAÇÕES   : 10/10/2016
 * --------------
 * 001: [04/05/2011] Rodolpho Telmo  (DB1) : Adaptação no formulário de avalista genérico
 * 002: [11/07/2011] Gabriel Capoia  (DB1) : Alterado para layout padrão
 * 003: [03/02/2012] Tiago        (CECRED) : Retirado a mascara do campo Observações
 * 004: [20/04/2012] Guilherme    (CECRED) : Digitalizacao.
 * 005: [24/04/2012] Tiago        (CECRED) : Esconder o botao de visualizar imagem dependendo
 *				                             do campo flgdigit e tornar link de visualizacao
 *							                 da imagem dinamico.
 * 006: [08/05/2012] Tiago        (CECRED) : Inserido codigo da cooperativa no link dinamico.
 * 007: [09/07/2012] Lucas        (CECRED) : Listagem de Linhas de Desconto de Título disponíveis.
 * 008: [06/11/2012] Adriano	  (CECRED) : Ajustes referente ao projeto GE.
 * 009: [02/01/2015] Fabrício     (CECRED) : Ajuste format numero contrato/bordero para consultar imagem 
                                             do contrato; adequacao ao format pre-definido para nao ocorrer 
					                         divergencia ao pesquisar no SmartShare.
                                             (Chamado 181988) - (Fabricio)
 * 010: [27/06/2016] Jaison/James (CECRED) : Inicializacao da aux_inconfi6.
 * 010: [10/10/2016] Lucas Ranghetti (CECRED): Remover verificacao de digitalizaco para o botao de consultar imagem(#510032)
 * 011: [26/06/2017] Jonata (RKAM): Ajuste para rotina ser chamada através da tela ATENDA > Produtos (P364).
 * 012: [28/03/2018] Andre Avila (GFT):  Alteração da opção retorno dos botões.
 * 013: [03/05/2018] Andre Avila (GFT):  Alteração da opção retorno do botão cancelar.
 * 014: [04/06/2019] Mateus Z  (Mouts) : Alteração para chamar tela de autorização quando alterar valor. PRJ 470 - SM2
 * 015: [29/05/2019] Luiz Otávio OM (AMCOM) : Adicionado Etapa Rating para Cooperatova Ailos (3)
 * 016: [18/07/2019] Mateus Z     (Mouts)  : Alterado layout da primeira tela de inclusão/alteração/consulta 
 *                                           (Dados do Limite) PRJ 438 - Sprint 16
 * 017: [19/07/2019] Rubens Lima    (Mouts): Exclusão do form Rendas e alteração dos fluxos da tela (PJ438 sprint 16)
 */
define('cooperativaCetralAilosEtapaRating', 3);
?>
<form action="" name="frmDadosLimiteDscTit" id="frmDadosLimiteDscTit" onSubmit="return false;">

	<input type="hidden" id="idcobert" value="<?php echo $dados[30]->cdata; ?>" />

	<div id="divDscTit_Limite">
	
		<fieldset>
		
			<legend><? echo utf8ToHtml('Dados da Solicitação') ?></legend>
			
			<input type="hidden" name="qtdiavig" id="qtdiavig" value="0">
			<input type="hidden" name="dsramati" id="dsramati" value="">
			<input type="hidden" name="vlmedtit" id="vlmedtit" value="0,00">
			<input type="hidden" name="vlfatura" id="vlfatura" value="0,00">
			<!-- PRJ 438 - Sprint 16 - Incluído o campo nivel de risco -->
			<label for="nivrisco"><? echo utf8ToHtml('Nível de Risco:') ?></label>
			<input type="text" name="nivrisco" id="nivrisco" value="" class="campoTelaSemBorda" disabled>
			<br />

			<? if ($cddopcao == "I") { ?>
			
				<input type="hidden" name="nrctrlim" id="nrctrlim" value="0" class="campo" disabled>
			
			<? } else { ?> 
				
				<label for="nrctrlim"><? echo utf8ToHtml('Número da Proposta:') ?></label>
			<input type="text" name="nrctrlim" id="nrctrlim" value="0" class="campo" disabled>
			<br />
			
			<? } ?>
			
			<label for="vllimite"><? echo utf8ToHtml('Valor do Limite:') ?></label>
			
			<input type="text" name="vllimite" id="vllimite" value="0,00" class="campo">
			
			<br />
			
			<label for="cddlinha"><? echo utf8ToHtml('Linha de descontos:') ?></label>
			<input type="text" name="cddlinha" id="cddlinha" value="0" class="campo codigo pesquisa">
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input type="text" name="cddlinh2" id="cddlinh2" value="" class="campoTelaSemBorda" disabled>
			<br />
			
			<!-- PRJ 438 - Sprint 16 - Incluído o campo taxa da linha de descontos -->
			<label for="txmensal"> <? echo utf8ToHtml('Taxa:') ?></label>
			<input name="txmensal" id="txmensal" type="text" value="" class="campoTelaSemBorda" disabled>
			
			<?
			// PRJ 438 - Sprint 16 - Incluído o campo data de cancelamento 
			// só mostra o campo de cancelamento se a opção for consulta e se exisitir uma data de cancelamento para exibir
			if($cddopcao == "C") {
				if (strlen($dados[18]->cdata) > 6) {
					?>
	 				<label for="dtcancel"><? echo utf8ToHtml('Data de Cancelamento:') ?></label>
					<input type="text" name="dtcancel" id="dtcancel" value="" class="campoTelaSemBorda" disabled>
					<?
				}
			}
			?>
		</fieldset>
		
	</div>
	
  <div id="divUsoGAROPC"></div>
  
  <div id="divFormGAROPC"></div>
			
			
			
		
	
  
	
	
		
								
				
				
				
				
								
		
	
	<div id="divDscTit_Observacao">
	
		<fieldset>
		
			<legend><? echo utf8ToHtml('Observações:') ?></legend>
			<textarea name="dsobserv" id="dsobserv" style="width: 450px;" rows="5" maxlength="953"></textarea>
						
		</fieldset>
				
	</div>
	
	<div id="divDscTit_Avalistas" class="condensado" >
	
		<? 	// ALTERAÇÃO 001: Substituido formulário antigo pelo include				
//			include('../../../../includes/avalistas/form_avalista.php'); 
			include('form_dados_aval.php');
		?>
		
	</div>
		
	<div id="divDscTit_Demonstracao">
		<fieldset id="fsDscTit_Demonstracao">
			<legend style="text-align: center !important;">
				<?	// alterar o titulo do legend conforme opção
					switch ($cddopcao) {
						case 'E': echo utf8ToHtml('Efetivação da Proposta'); break;							        // Efetivar
						default:  echo utf8ToHtml('Demonstração do Limite de Desconto de T&iacute;tulos'); break;	// Outras opções
					}
				?>
			</legend>
			<label for="demoNivrisco" class="rotulo txtNormalBold"><? echo utf8ToHtml('Nível de Risco:') ?></label>
			<input type="text" name="demoNivrisco" id="demoNivrisco" value="" class="campo">
			<br /><br />

			<? if ($cddopcao != "I") { ?>
			
				<label for="demoNrctrlim" class="rotulo txtNormalBold"><? echo utf8ToHtml('Número da Proposta:') ?></label>
				<input type="text" name="demoNrctrlim" id="demoNrctrlim" value="" class="campo">
				<br /><br />
			
			<? } ?>

			<label for="demoVllimite" class="rotulo txtNormalBold"><? echo utf8ToHtml('Valor do Limite:') ?></label>
			<input type="text" name="demoVllimite" id="demoVllimite" value="" class="campo">
			<br /><br />
			<label for="demoCddlinha" class="rotulo txtNormalBold"><? echo utf8ToHtml('Linha de Crédito:') ?></label>
			<input type="text" name="demoCddlinha" id="demoCddlinha" value="" class="campo">
			<br /><br />
			<label for="demoTxmensal" class="rotulo txtNormalBold"><? echo utf8ToHtml('Taxa:') ?></label>
			<input type="text" name="demoTxmensal" id="demoTxmensal" value="" class="campo">
			<br /><br />
			<label for="demoQtdiavig" class="rotulo txtNormalBold"><? echo utf8ToHtml('Vigência:') ?></label>
			<input type="text" name="demoQtdiavig" id="demoQtdiavig" value="" class="campo">
		</fieldset>
		<script type="text/javascript">
			// formatações CSS da demonstração
		    $('label','#fsDscTit_Demonstracao').css({ 'width': '120px' });
		    $('legend','#fsDscTit_Demonstracao').css({ 'margin-bottom': '10px' });
		    $('#fsDscTit_Demonstracao').css({ 'width':'320px' });
		    $('input[type="text"]','#fsDscTit_Demonstracao').css({ 'width':'180px' });
			$("input[type='text']","#fsDscTit_Demonstracao").prop("disabled",true).attr("class","campoTelaSemBorda");
		</script>
	</div>
</form>

<div id="divBotoesLimite">
		
	<input type="image" id="btnVoltarLimite" name="btnVoltarLimite" src="<? echo $UrlImagens; ?>botoes/voltar.gif" />
	
	
	<? if ($cddopcao == "C") { ?> 
				<a href="http://<?php 

				echo $GEDServidor;?>/smartshare/clientes/viewerexterno.aspx?tpdoc=<?php 
				echo $dados[29]->cdata; ?>&conta=<?php 
				echo formataContaDVsimples($nrdconta); ?>&contrato=<?php 
				echo formataNumericos('z.zzz.zz9',$nrctrlim,'.'); ?>&cooperativa=<?php 
				echo $glbvars["cdcooper"]; ?>" target="_blank"><img src="<? 
				echo $UrlImagens; ?>botoes/consultar_imagem.gif" /></a>
	<?	} ?>
	   
	<input type="image" id="btnContinuarLimite" name="btnContinuarLimite" src="<? echo $UrlImagens; ?>botoes/continuar.gif" />		
	
</div>

<div id="divBotoesGAROPC">

  <input type="image" id="btnVoltarGAROPC" name="btnVoltarGAROPC" src="<? echo $UrlImagens; ?>botoes/voltar.gif" />
	<input type="image" id="btnContinuarGAROPC" name="btnContinuarGAROPC" src="<? echo $UrlImagens; ?>botoes/continuar.gif" />

</div>

		
	
	

<div id="divBotoesObs" >
		
	<input type="image" id="btnVoltarObservacao" name="btnVoltarObservacao" src="<? echo $UrlImagens; ?>botoes/voltar.gif" />
	<input type="image" id="btnContinuarObservacao" name="btnContinuarObservacao" src="<? echo $UrlImagens; ?>botoes/continuar.gif" />
	
</div>

<div id="divBotoesAval">						
		
	<input type="image" id="btnVoltarAvalistas" name="btnVoltarAvalistas" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="controlaVoltarAvalista();">
	<? if ($cddopcao == "I" || $cddopcao == "A") { ?>
		<input type="image" id="btnLimparAvalista" src="<? echo $UrlImagens; ?>botoes/limpar.gif" onClick="limpaFormAvalistas(true);">
	<? } ?>
	<input type="image" id="btContinuarAvalistas" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaContinuarAvalista();">
			
</div>	

<div id="divBotoesDemo">
<? 
		if ($cddopcao == "E") {
			echo ' <input type="image" id="btnVoltarDemonstracaoE" 	name="btnVoltarDemonstracaoE" 	src="'.$UrlImagens.'botoes/voltar.gif"> ';
			echo ' <input type="image" id="btnConcluirLimiteE" 		name="btnConcluirLimiteE" 		src="'.$UrlImagens.'botoes/concluir.gif"> ';
 		} else {
			echo ' <input type="image" id="btnVoltarDemonstracao" 	name="btnVoltarDemonstracao" 	src="'.$UrlImagens.'botoes/voltar.gif"> ';
			if ($cddopcao == "I" || $cddopcao == "A") {
				echo ' <input type="image" id="btnCancelarLimite" 	name="btnCancelarLimite" 		src="'.$UrlImagens.'botoes/cancelar.gif"> ';
			}
			echo ' <input type="image" id="btnConcluirLimite"		name="btnConcluirLimite" 		src="'.$UrlImagens.'botoes/concluir.gif"> ';
		}
	?>
</div>
<? 
	if ($cddopcao <> "I") {
		// Alimentar dados do rating - Variáveis utilizadas na include rating_busca_dados.php	
		$nrgarope = $dados[21]->cdata;
		$nrinfcad = $dados[22]->cdata;
		$nrliquid = $dados[23]->cdata;
		$nrpatlvr = $dados[24]->cdata;
		$vltotsfn = $dados[25]->cdata;
		$nrperger = $dados[26]->cdata;
		$perfatcl = $dados[27]->cdata;
	}
	
	// Variável que indica se é uma operação para cadastrar nova proposta - Utiliza na include rating_busca_dados.php
	$cdOperacao = $cddopcao;
	if ($glbvars["cdcooper"] == cooperativaCetralAilosEtapaRating) {
		include("../../../../includes/rating/rating_busca_dados.php"); 
	} 
?>

<script type="text/javascript">

	var habrat = '<?=$habrat?>';

	// PJ438 - Sprint 16
	function continuarRating(showContinuar, showVoltar, execContinuar, execVoltar) {

		var divHide = showVoltar.split(";");		
		for (var i = 0; i < divHide.length; i++) {
			$("#" + divHide[i]).css("display","none");
		}	

		if (operacao == 'A') {
			var aux_vllimite = normalizaNumero($("#vllimite","#frmDadosLimiteDscTit").val());
			aux_vllimite_anterior = normalizaNumero(aux_vllimite_anterior);
			if(aux_vllimite_anterior != aux_vllimite){
				aux_fncRatingSuccess = "chamarImpressao('PROPOSTA');";
			} else {
				aux_fncRatingSuccess = "carregaLimitesTitulosPropostas();";
			}
			/*Motor em contingencia*/
			if(flctgmot && habrat == 'N'){
				informarRating('',"dscShowHideDiv('"+showContinuar+"','divDadosRating');"+execContinuar,"dscShowHideDiv('"+showVoltar+"','divDadosRating');"+execVoltar,aux_fncRatingSuccess);
			}else{
				fncRatingSuccess = aux_fncRatingSuccess;
				dscShowHideDiv(showContinuar,showVoltar);
				eval(execContinuar);
			}
		} else if (operacao == 'C') {
			aux_fncRatingSuccess = "carregaLimitesTitulos();";
			if (habrat == 'N') {
				informarRating('',"dscShowHideDiv('"+showContinuar+"','divDadosRating');"+execContinuar,"dscShowHideDiv('"+showVoltar+"','divDadosRating');"+execVoltar,aux_fncRatingSuccess);
			} else {
				fncRatingSuccess = aux_fncRatingSuccess;
				dscShowHideDiv(showContinuar,showVoltar);				
				eval(execContinuar);
			}
		} else {
			aux_fncRatingSuccess = "chamarImpressao('PROPOSTA');";
			//bruno - prj 470 - tela autorizacao
			if (habrat == 'N') {
				informarRating('',"dscShowHideDiv('"+showContinuar+"','divDadosRating')"+execContinuar,"dscShowHideDiv('"+showVoltar+"','divDadosRating');"+execVoltar,aux_fncRatingSuccess);
			} else {
				fncRatingSuccess = aux_fncRatingSuccess;
				dscShowHideDiv(showContinuar,showVoltar);				
				eval(execContinuar);
			}
		}

		return false;

	}

	formataLayout('frmDadosLimiteDscTit');

	operacao = '<? echo $cddopcao; ?>';
	
    if (operacao == "E") {
		dscShowHideDiv("divOpcoesDaOpcao3;divDscTit_Demonstracao;divBotoesDemo","divDscTit_Limite;divBotoesLimite;divBotoesGAROPC;divBotoesObs;divBotoesAval;divOpcoesDaOpcao2;divDscTit_Observacao;divDscTit_Avalistas");
	} else {
		dscShowHideDiv("divOpcoesDaOpcao3;divDscTit_Limite;divBotoesLimite","divBotoesGAROPC;divBotoesObs;divBotoesDemo;divBotoesAval;divOpcoesDaOpcao2;divDscTit_Observacao;divDscTit_Demonstracao;divDscTit_Avalistas");
		// [018]
	}

	var arrayAvalistas = new Array();
	if (operacao == 'I') {
		var nrAvalistas = 0;
		var contAvalistas = 1;
	}
	if (operacao == 'C') {
            $('#nrctaava','#divDscTit_Avalistas').prop('disabled', true);
			$('#nrctaava','#divDscTit_Avalistas').addClass( "campoTelaSemBorda" );
	}

		
	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - LIMITE - <? if ($cddopcao == "A") { echo "ALTERAR"; } elseif ($cddopcao == "C") { echo "CONSULTAR"; } else { echo "INCLUIR"; } ?>");

	<? 
	// Alimentar campos do formulário para gerenciar limite
	if ($cddopcao == "I") { 
		echo '$("#qtdiavig","#frmDadosLimiteDscTit").val("'.formataNumericos('zzz.zz9',$dados[6]->cdata,'.').' dias");';
		// PRJ 438 - Sprint 16 - Incluido nivel de risco (nasce com valor A)
		echo '$("#nivrisco","#frmDadosLimiteDscTit").val("A");';
	} else { 
		echo '$("#nrctrlim","#frmDadosLimiteDscTit").val("'.formataNumericos('z.zzz.zz9',$dados[14]->cdata,'.').'");';
		echo '$("#vllimite","#frmDadosLimiteDscTit").val("'.number_format(str_replace(",",".",$dados[15]->cdata),2,",",".").'");';
		echo '$("#qtdiavig","#frmDadosLimiteDscTit").val("'.formataNumericos('zzz.zz9',$dados[16]->cdata,'.').' dias");';
		echo '$("#cddlinha","#frmDadosLimiteDscTit").val("'.formataNumericos('zz9',$dados[17]->cdata,'.').'");';
		echo '$("#cddlinh2","#frmDadosLimiteDscTit").val("'.$dados[2]->cdata.'");';
		echo '$("#dsramati","#frmDadosLimiteDscTit").val("'.$dados[4]->cdata.'");';
		echo '$("#vlmedtit","#frmDadosLimiteDscTit").val("'.number_format(str_replace(",",".",$dados[5]->cdata),2,",",".").'");';
		echo '$("#vlfatura","#frmDadosLimiteDscTit").val("'.number_format(str_replace(",",".",$dados[6]->cdata),2,",",".").'");';
		echo '$("#vlsalari","#frmDadosLimiteDscTit").val("'.number_format(str_replace(",",".",$dados[8]->cdata),2,",",".").'");';
		echo '$("#vlsalcon","#frmDadosLimiteDscTit").val("'.number_format(str_replace(",",".",$dados[9]->cdata),2,",",".").'");';
		echo '$("#vloutras","#frmDadosLimiteDscTit").val("'.number_format(str_replace(",",".",$dados[7]->cdata),2,",",".").'");';
		echo '$("#dsdbens1","#frmDadosLimiteDscTit").val("'.trim($dados[10]->cdata).'");';
		echo '$("#dsdbens2","#frmDadosLimiteDscTit").val("'.trim($dados[11]->cdata).'");';	
		echo '$("#dsobserv","#frmDadosLimiteDscTit").val("'.str_replace(chr(13),"\\n",str_replace(chr(10),"\\r",$dados[12]->cdata)).'");';
		echo '$("#antnrctr","#frmDadosLimiteDscTit").val("'.formataNumericos('zzz.zz9',$dados[14]->cdata,'.').'");';
		// Pj470 - SM2 -- Mateus Zimmermann -- Mouts
		echo 'aux_vllimite_anterior = "'.number_format(str_replace(",",".",$dados[15]->cdata),2,",",".").'";';
		// Fim Pj470 - SM2
		// PRJ 438 - Sprint 16 - Incluido nivel de risco e taxa
		echo '$("#nivrisco","#frmDadosLimiteDscTit").val("'.$dados[31]->cdata.'");';
		echo '$("#txmensal","#frmDadosLimiteDscTit").val("'.$dados[32]->cdata.'");';
		echo '$("#dtcancel","#frmDadosLimiteDscTit").val("'.$dados[18]->cdata.'");';
		/*
		 *
		 * Preencher os dados da tela de demonstração
		 *
		 */
		echo '$("#demoNivrisco","#divDscTit_Demonstracao").val( $("#nivrisco","#frmDadosLimiteDscTit").val() );';
		echo '$("#demoNrctrlim","#divDscTit_Demonstracao").val("'.formataNumericos('z.zzz.zz9',$dados[14]->cdata,'.').'");';
		echo '$("#demoVllimite","#divDscTit_Demonstracao").val("'.number_format(str_replace(",",".",$dados[15]->cdata),2,",",".").'");';

		$cdlinhaConcat = formataNumericos('zz9',$dados[17]->cdata,'.') . ' ' . $dados[2]->cdata;
		echo '$("#demoCddlinha","#divDscTit_Demonstracao").val("'.$cdlinhaConcat.'");';

		echo '$("#demoTxmensal","#divDscTit_Demonstracao").val("'.number_format(str_replace(",",".",$dados[0]->cdata),6,",",".").'%");';
		echo '$("#demoQtdiavig","#divDscTit_Demonstracao").val("'.formataNumericos('zzz.zz9',$dados[16]->cdata,'.').' dias");';

	}
	?>
	
	// Na consulta não permitir manipulação dos campos
	if (operacao == 'C' || operacao == 'E') {
	
		$("input[type='text']",'#'+nomeForm).prop("disabled",true).attr("class","campoTelaSemBorda");
		$("textarea",'#'+nomeForm).attr("readonly",true);
		$("select",'#'+nomeForm).prop("disabled",true);
	
	// Para demais operações, configurar máscaras para campos do formulário
	} else {
	
		if (operacao == 'A' || operacao == 'I' ) {
			$("#nrctrlim",'#'+nomeForm).prop("disabled",true).attr("class","campoTelaSemBorda");
		} 
	
		// Dados do Limite	
		$("#nrctrlim",'#'+nomeForm).setMask("INTEGER","z.zzz.zz9","");
		$("#vllimite",'#'+nomeForm).setMask("DECIMAL","zzz.zzz.zz9,99","");
		$("#vlmedtit",'#'+nomeForm).setMask("DECIMAL","z.zzz.zz9,99","");
		$("#vlfatura",'#'+nomeForm).setMask("DECIMAL","zzz.zzz.zz9,99","");
		$("#dsramati",'#'+nomeForm).setMask("STRING","40",charPermitido(),"");


	}

	// Atribui eventos para botões do formulário
	$('#btnVoltarLimite','#divBotoesLimite').unbind('click').bind('click',function() {
		
		if(executandoProdutos){
			
			encerraRotina(true);
			
		}else{
			
		voltaDiv(3,2,4,'DESCONTO DE T&Iacute;TULOS - LIMITE');
			
		}
		return false;
	});
	
	//PRJ 438 - Sprint 16
	$('#btnContinuarLimite','#divBotoesLimite').unbind('click').bind('click',function() {
		if (operacao == 'C') {
      <? if ($dados[30]->cdata > 0) { ?>
			abrirTelaGAROPC("C");
      blockBackground(parseInt($("#divRotina").css("z-index")));
      <? // } else if ($dados[12]->cdata > 0) { ?>
//			continuarRating("divDscTit_Observacao;divBotoesObs","divDscTit_Limite;divBotoesLimite");
      <? } else { ?>
			continuarRating("","divDscTit_Limite;divBotoesLimite","$('#btnContinuarObservacao', '#divBotoesObs').trigger('click');","");
      <? } ?>
		} else {
			aux_inconfir = 1; 
			aux_inconfi2 = 11; 
			aux_inconfi3 = ""; 
			aux_inconfi4 = 71; 
			aux_inconfi5 = 30;
			aux_inconfi6 = 51;
			validaLimiteDscTit(operacao,1,11,30);
		}
		return false;
	});
	
  $("#btnVoltarGAROPC","#divBotoesGAROPC").unbind("click").bind("click",function() {
    $("#divUsoGAROPC").empty();
    $("#divFormGAROPC").empty();
    $("#frmDadosLimiteDscTit").css("width", 515);
    dscShowHideDiv("divDscTit_Limite;divBotoesLimite", "divFormGAROPC;divBotoesGAROPC");
		return false;
	});
	
    //PRJ 438 - Sprint 16	
  $("#btnContinuarGAROPC","#divBotoesGAROPC").unbind("click").bind("click",function() {
	let aux = '';
//	if ($('#dsobserv','#divDscTit_Observacao').val() == '' && operacao == 'C') {
	  aux = 'continuarRating("","divFormGAROPC;divBotoesGAROPC","$(\'#btnContinuarObservacao\', \'#divBotoesObs\').trigger(\'click\');","$(\'#frmDadosLimiteDscTit\').css(\'width\', 540);");';
//	} else {
//	  aux = 'continuarRating("divDscTit_Observacao;divBotoesObs","divFormGAROPC;divBotoesGAROPC","","$(\'#frmDadosLimiteDscTit\').css(\'width\', 540);");';
//	}
  	gravarGAROPC('idcobert','frmDadosLimiteDscTit',aux+'$("#frmDadosLimiteDscTit").css("width", 515);bloqueiaFundo($("#divDscTit_Observacao"));');
    return false;
	});
	
	//PRJ 438 - Sprint 16
	$('#btnVoltarObservacao','#divBotoesObs').unbind('click').bind('click',function() {
		if(operacao == 'A' && flctgmot && habrat == 'N'){
			dscShowHideDiv('divDadosRating','divDscTit_Observacao;divBotoesObs');
			return false;
		} else if (habrat == 'N') {
			dscShowHideDiv('divDadosRating','divDscTit_Observacao;divBotoesObs');
			return false;
		} else {
    <? if ($cddopcao == "C") { ?>
      <? if ($dados[30]->cdata > 0) { ?>
        			dscShowHideDiv('divFormGAROPC;divBotoesGAROPC','divDscTit_Observacao;divBotoesObs');
        $("#frmDadosLimiteDscTit").css("width", 540);
      <? } else { ?>
        			dscShowHideDiv('divDscTit_Limite;divBotoesLimite','divDscTit_Observacao;divBotoesObs');
      <? } ?>      
    <? } else if ($cddopcao == "A" || $cddopcao == "I") { ?>
        		dscShowHideDiv('divFormGAROPC;divBotoesGAROPC','divDscTit_Observacao;divBotoesObs');
      $("#frmDadosLimiteDscTit").css("width", 540);
    <? } else { ?>
				dscShowHideDiv('divDscTit_Limite;divBotoesLimite','divDscTit_Observacao;divBotoesObs');
    <? } ?>
		}
		return false;
	});
	
	$('#btnContinuarObservacao','#divBotoesObs').unbind('click').bind('click',function() {
		if(nrAvalistas == 0 && operacao == 'C') {
			$("#frmDadosLimiteDscTit").css("width", 525);
			dscShowHideDiv("divDscTit_Demonstracao;divBotoesDemo","divDscTit_Observacao;divBotoesObs");
			preencherDemonstracao();
			return false;
			}
		if(nrAvalistas > 0){
			atualizarCamposTelaAvalistas();
		}
	    $("#frmDadosLimiteDscTit").css("width", 525);
		dscShowHideDiv('divDscTit_Avalistas;divBotoesAval','divDscTit_Observacao;divBotoesObs');
		return false;
	
	});
	
	$("#btnVoltarDemonstracao","#divBotoesDemo").unbind("click").bind("click",function() {
		if(nrAvalistas == 0 && operacao == 'C') {
//			if ($('#dsobserv','#divDscTit_Observacao').val() != '') {
//				$("#frmDadosLimiteDscTit").css("width", 515);
//				dscShowHideDiv("divDscTit_Observacao;divBotoesObs","divDscTit_Demonstracao;divBotoesDemo");
//			} else {
				dscShowHideDiv('','divDscTit_Demonstracao;divBotoesDemo');	  
				$('#btnVoltarObservacao', '#divBotoesObs').trigger('click');
//			}
			return false;
		}
	 	abrirTelaDemoDescontoTitulo(false);
		return false;
	});
	$("#btnVoltarDemonstracaoE","#divBotoesDemo").unbind("click").bind("click",function() {
		voltaDiv(3,2,4,"DESCONTO DE T&Iacute;TULOS - LIMITE");
		return false;
	});
	$("#btnConcluirLimiteE","#divBotoesDemo").unbind("click").bind("click",function() {
        showConfirmacao('Deseja confirmar opera&ccedil&atildeo?','Confirma&ccedil&atildeo - Aimaro','confirmaNovoLimite();voltaDiv(3,2,4,"DESCONTO DE T&Iacute;TULOS - LIMITE");','metodoBlock();','sim.gif','nao.gif');
		return false;
	});
	if (operacao != 'C') {
		$('#btnCancelarLimite','#divBotoesDemo').unbind('click').bind('click',function() {


    showConfirmacao(
        "Deseja cancelar a opera&ccedil;&atilde;o?",
        "Confirma&ccedil;&atilde;o - Aimaro",
		"carregaLimitesTitulosPropostas();",
        "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))",
        "sim.gif",
        "nao.gif");
		});
	}
	
	$('#btnConcluirLimite','#divBotoesDemo').unbind('click').bind('click',function() {
		if (operacao == 'C') {
			voltaDiv(3,2,4,'DESCONTO DE T&Iacute;TULOS - LIMITE');
		} else {
			buscaGrupoEconomico();
		}
		return false;
	});
	
	$('#nrctrlim','#frmDadosLimiteDscTit').focus();
				
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);	
	
</script>