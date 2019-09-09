<? 
/*!
 * FONTE        : cheques_limite_formulario.php
 * CRIAÇÃO      : David
 * DATA CRIAÇÃO : Junho/2007
 * OBJETIVO     : Carregar formulário de dados para gerenciar limite
 * --------------
 * ALTERAÇÕES   : 11/12/2017
 * --------------
 * 001: [04/05/2011] Rodolpho Telmo  (DB1) : Adaptação no formulário de avalista genérico
 * 002: [11/07/2011] Gabriel Capoia  (DB1) : Alterado para layout padrão
 * 003: [03/02/2012] Tiago        (CECRED) : Retirado a mascara do campo Observação.
 * 004: [20/04/2012] Guilherme    (CECRED) : Digitalizacao.
 * 005: [25/04/2012] Tiago        (CECRED) : Esconder o botao de visualizar imagem dependendo
 *				                             do campo flgdigit e tornar link de visualizacao
 *							                 da imagem dinamico.
 * 006: [08/05/2012] Tiago        (CECRED) : Incluido codigo cooperativa no link dinamico.
 * 007: [15/10/2012] Lucas    	  (CECRED) : Ajuste em label de Val. Méd. dos Cheques.
 * 008: [21/11/2012] Adriano	  (CECRED) : Ajuste referente ao projeto GE.
 * 009: [02/01/2015] Fabrício     (CECRED) : Ajuste format numero contrato/bordero para consultar imagem 
                                             do contrato; adequacao ao format pre-definido para nao ocorrer 
					                         divergencia ao pesquisar no SmartShare.
                                             (Chamado 181988) - (Fabricio)
 * 010: [13/10/2015] Kelvin 	  (CECRED) : Adicionado validação para não permitir valor de limite
											 zero. SD 325240 (Kelvin).
 * 011: [20/06/2016] Jaison/James (CECRED) : Inicializacao da aux_inconfi6.
 * 011: [10/10/2016] Lucas Ranghetti (CECRED): Remover verificacao de digitalizaco para o botao de consultar imagem(#510032)
 * 012: [26/05/2017] Odirlei Busana (AMcom)  : Desabilitar campo de numero do contrato, será gerado automaticamente. PRJ300 - desconto de cheque
 * 013: [26/06/2017] Jonata            (RKAM): Ajuste para rotina ser chamada através da tela ATENDA > Produtos ( P364)
 * 014: [11/12/2017] P404 - Inclusão de Garantia de Cobertura das Operações de Crédito (Augusto / Marcos (Supero))
 * 015: [13/04/2018] Lombardi     (CECRED) : Incluida chamada da function validaValorProduto. PRJ366
 * 016: [04/06/2019] Mateus Z      (Mouts) : Alteração para chamar tela de autorização quando alterar valor. PRJ 470 SM2
 * 017: [29/03/2019] Luiz Otávio (AMCOM)     : Retirado etapa Rating - P450
 * 018: [08/07/2019] Mateus Z      (Mouts) : Alterações referentes a remoção da tela de Rendas PRJ 438 - Sprint 14.
 * 019: [09/07/2019] Mateus Z     (Mouts)  : Alterado layout da primeira tela de inclusão/alteração/consulta (Dados do Limite) PRJ 438 - Sprint 14
 * 020: [05/07/2019] Anderson Schloegel (Mout's): Incluir tela de demonstração de limite de desconto de cheques (pj438 sprint 14 story 12079)
 */

// ********************************************
// AMCOM - Retira Etapa Rating exceto para Ailos (coop 3)

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "   <cdacesso>HABILITA_RATING_NOVO</cdacesso>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_PARRAT", "CONSULTA_PARAM_CRAPPRM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjPRM = getObjectXML($xmlResult);

$habrat = 'N';
if (strtoupper($xmlObjPRM->roottag->tags[0]->name) == "ERRO") {
	$habrat = 'N';
} else {
	$habrat = $xmlObjPRM->roottag->tags[0]->tags;
	$habrat = getByTagName($habrat[0]->tags, 'PR_DSVLRPRM');
}

if ($glbvars["cdcooper"] == 3) {
	$habrat = 'N';
}
// ********************************************

?>
<script type="text/javascript">
	var habrat = '<?=$habrat?>';
</script>

<form action="" name="frmDadosLimiteDscChq" id="frmDadosLimiteDscChq">

  <input type="hidden" id="idcobert" value="<?php echo $dados[33]->cdata; ?>" />

	<div id="divDscChq_Limite">
	
		<fieldset>
		
			<legend><? echo utf8ToHtml('Dados da Solicitação') ?></legend>
			
			<input type="hidden" name="qtdiavig" id="qtdiavig" value="0">
			<input type="hidden" name="dsramati" id="dsramati" value="">
			<input type="hidden" name="vlmedtit" id="vlmedtit" value="0,00">
			<input type="hidden" name="vlfatura" id="vlfatura" value="0,00">
			<label for="nivrisco"><? echo utf8ToHtml('Nível de Risco:') ?></label>
			<input type="text" name="nivrisco" id="nivrisco" value="" class="campoTelaSemBorda" disabled>
			<br />
			
			<? if ($cddopcao == "I") { ?>
			
				<input type="hidden" name="nrctrlim" id="nrctrlim" value="0" class="campo" disabled>
			
			<? } else { ?> 
				
				<label for="nrctrlim"><? echo utf8ToHtml('Número do Contrato:') ?></label>
				<input type="text" name="nrctrlim" id="nrctrlim" value="0" class="campo" disabled>
			<br />
			
			<? } ?>
			
			<label for="vllimite"><? echo utf8ToHtml('Valor do Limite:') ?></label>
			<input type="text" name="vllimite" id="vllimite" value="" class="campo">
			
			<br />
			
			<label for="cddlinha"><? echo utf8ToHtml('Linha de Descontos:') ?></label>
			<input type="text" name="cddlinha" id="cddlinha" value="" class="campo codigo pesquisa">
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input type="text" name="cddlinh2" id="cddlinh2" value="" class="campoTelaSemBorda" disabled>
			<br />
			
			<!-- PRJ 438 - Sprint 14 - Incluído o campo taxa da linha de crédito -->
			<label for="txmensal"> <? echo utf8ToHtml('Taxa:') ?></label>
			<input name="txmensal" id="txmensal" type="text" value="" class="campoTelaSemBorda" disabled>
			<br>
			
			<?
			// só mostra o campo de cancelamento se a opção for diferente de incluir
			if($cddopcao != "I") {
				// verifica se tem dados dentro do campo de data de cancelamento
				if (strlen($dados[18]->cdata) > 6) {
					// se sim, exibe o campo de data
					?>
			
			
			<label for="dtcancel"><? echo utf8ToHtml('Data de cancelamento:') ?></label>
			<input type="text" name="dtcancel" id="dtcancel" value="" class="campoTelaSemBorda" disabled>
					<?
				}
			}
			?>
		</fieldset>
				
	</div>
	
  <div id="divUsoGAROPC"></div>
  
  <div id="divFormGAROPC"></div>
	
	
		
								
				
				
				
				
								
		
	
	<div id="divDscChq_Observacao">
	
		<fieldset>
		
			<legend><? echo utf8ToHtml('Observações:') ?></legend>
			
			<textarea name="dsobserv" id="dsobserv" style="width: 450px;" rows="5" maxlength="953" ></textarea>
						
		</fieldset>
				
	</div>
	
	<!-- [020] -->
	<div id="divDscChq_Demonstracao">		

		<fieldset id="fsDscChq_Demonstracao">

			<legend style="text-align: center !important;">
				<?	// alterar o titulo do legend conforme opção
					switch ($cddopcao) {
						case 'E': echo utf8ToHtml('Efetivação da Proposta'); break;							// Efetivar
						default:  echo utf8ToHtml('Demonstração do Limite de Desconto de Cheques'); break;	// Outras opções
					}
				?>
			</legend>

			<label for="demoNivrisco" class="rotulo txtNormalBold"><? echo utf8ToHtml('Nível de Risco:') ?></label>
			<input type="text" name="demoNivrisco" id="demoNivrisco" value="" class="campo">
			<br /><br />

			<? if ($cddopcao != "I") { ?>
			
				<label for="demoNrctrlim" class="rotulo txtNormalBold"><? echo utf8ToHtml('Número do Contrato:') ?></label>
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
		    $('label','#fsDscChq_Demonstracao').css({ 'width': '120px' });
		    $('legend','#fsDscChq_Demonstracao').css({ 'margin-bottom': '10px' });
		    $('#fsDscChq_Demonstracao').css({ 'width':'320px' });
//		    $('#divRotina').css({ 'z-index':'201' }); // PJ438 - Bug 24421
		    $('input[type="text"]','#fsDscChq_Demonstracao').css({ 'width':'180px' });
			$("input[type='text']","#fsDscChq_Demonstracao").prop("disabled",true).attr("class","campoTelaSemBorda");

		</script>

	</div>

	<!-- fim [020] -->

	<div id="divDscChq_Avalistas" class="formulario condensado" >
		<? 
			// ALTERAÇÃO 001: Substituido formulário antigo pelo include				
//			include('../../../../includes/avalistas/form_avalista.php'); 
			include('form_dados_aval.php');
		?>	
		
	</div>
	
</form>

<div id="divBotoesLimite">

	<input type="image" id="btnVoltarLimite" name="btnVoltarLimite" src="<? echo $UrlImagens; ?>botoes/voltar.gif" />
	
	<? if ($cddopcao == "C") { ?>
			<a href="http://<?php echo $GEDServidor;?>/smartshare/clientes/viewerexterno.aspx?tpdoc=<?php echo $dados[29]->cdata; ?>&conta=<?php echo formataContaDVsimples($nrdconta); ?>&contrato=<?php echo formataNumericos('z.zzz.zz9',$nrctrlim,'.'); ?>&cooperativa=<?php echo $glbvars["cdcooper"]; ?>" target="_blank"><img src="<? echo $UrlImagens; ?>botoes/consultar_imagem.gif" /></a>
	<? } ?>
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

<!-- [020] -->
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
<!-- fim [020]-->
<?
	if ($cddopcao <> "I") {
		// Alimentar dados do rating - Variáveis utilizadas na include rating_busca_dados.php	
		$nrgarope = $dados[21]->cdata;
		$nrinfcad = $dados[22]->cdata;
		$nrliquid = $dados[23]->cdata;
		$nrpatlvr = $dados[24]->cdata;
		$nrperger = $dados[25]->cdata;
		$vltotsfn = $dados[26]->cdata;
		$perfatcl = $dados[27]->cdata;
	}

	// Variável que indica se é uma operação para cadastrar nova proposta - Utiliza na include rating_busca_dados.php
	$cdOperacao = $cddopcao;

	if ($habrat == 'N') {
	include("../../../../includes/rating/rating_busca_dados.php"); 
	}
?>

<script type="text/javascript">

	// PJ438 - Sprint 14
	function continuarRating(showContinuar, showVoltar, execContinuar, execVoltar) {

		var divHide = showVoltar.split(";");		
		for (var i = 0; i < divHide.length; i++) {
			$("#" + divHide[i]).css("display","none");
		}	

		<? if ($cddopcao == "A") { ?>
			// Rating Antigo
			if (habrat == 'N') {
				// Pj470 - SM2 -- Mateus Zimmermann -- Mouts 
				var aux_vllimite = normalizaNumero($("#vllimite","#frmDadosLimiteDscChq").val());
				aux_vllimite_anterior = normalizaNumero(aux_vllimite_anterior);
				var aux_fncRatingSuccess = '';
				if(aux_vllimite_anterior != aux_vllimite){
					aux_fncRatingSuccess = "chamarImpressaoChequeLimite();";
				}else{
					aux_fncRatingSuccess = "carregaLimitesCheques();";
				}
				informarRating("","dscShowHideDiv('"+showContinuar+"','divDadosRating');"+execContinuar,"dscShowHideDiv('"+showVoltar+"','divDadosRating');"+execVoltar, aux_fncRatingSuccess);
				// Fim Pj470 - SM2
			// Rating Novo
			} else {
				// Pj470 - SM2 -- Mateus Zimmermann -- Mouts 
				var aux_vllimite = normalizaNumero($("#vllimite","#frmDadosLimiteDscChq").val());
				aux_vllimite_anterior = normalizaNumero(aux_vllimite_anterior);
				var aux_fncRatingSuccess = '';
				if(aux_vllimite_anterior != aux_vllimite){
					aux_fncRatingSuccess = "chamarImpressaoChequeLimite();";
				}else{
					aux_fncRatingSuccess = "carregaLimitesCheques();";
				}

				dscShowHideDiv(showContinuar,'divDadosRating');
				// Fim Pj470 - SM2
			}
			// Fim Rating
		<? } elseif ($cddopcao == "C") { ?>
			// Rating Antigo
			if (habrat == 'N') {
				informarRating("","dscShowHideDiv('"+showContinuar+"','divDadosRating');"+execContinuar,"dscShowHideDiv('"+showVoltar+"','divDadosRating');"+execVoltar,"carregaLimitesCheques();");
			// Rating Novo
			} else {
				dscShowHideDiv(showContinuar,'divDadosRating');
			}
			// Fim Rating
		<? } else { ?>
			// Rating Antigo
			if (habrat == 'N') {
				//prj 470 - tela autorizacao
				informarRating("",
							   "dscShowHideDiv('"+showContinuar+"','divDadosRating');"+execContinuar,
							   "dscShowHideDiv('"+showVoltar+"','divDadosRating');"+execVoltar,
							   "chamarImpressaoChequeLimite();");
			// Rating Novo
			} else {
				dscShowHideDiv(showContinuar,'divDadosRating');
			}
			// Fim Rating
		<? } ?>	
	}

	formataLayout('frmDadosLimiteDscChq');
	
	operacao = '<? echo $cddopcao; ?>';
    if (operacao == "E") {
		dscShowHideDiv("divOpcoesDaOpcao3;divDscChq_Demonstracao;divBotoesDemo","divDscChq_Limite;divBotoesLimite;divBotoesGAROPC;divBotoesObs;divBotoesAval;divOpcoesDaOpcao2;divDscChq_Observacao;divDscChq_Avalistas");
	} else {
		dscShowHideDiv("divOpcoesDaOpcao3;divDscChq_Limite;divBotoesLimite","divBotoesGAROPC;divBotoesObs;divBotoesAval;divBotoesDemo;divOpcoesDaOpcao2;divDscChq_Observacao;divDscChq_Avalistas;divDscChq_Demonstracao");
		// [020]
	}
	
	var arrayAvalistas = new Array();
	if (operacao == 'I') {
		var nrAvalistas = 0;
		var contAvalistas = 1;
	}
		
	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE CHEQUES - LIMITE - <? if ($cddopcao == "A") { echo "ALTERAR"; } elseif ($cddopcao == "C") { echo "CONSULTAR"; } else { echo "INCLUIR"; } ?>");

	<? 
	// Alimentar campos do formulário para gerenciar limite
	if ($cddopcao == "I") { 
		echo '$("#qtdiavig","#frmDadosLimiteDscChq").val("'.formataNumericos('zzz.zz9',$dados[4]->cdata,'.').' dias");';
		// PRJ 438 - Sprint 14 - Incluido nivel de risco (nasce com valor A)
		echo '$("#nivrisco","#frmDadosLimiteDscChq").val("A");';
	} else { 
		echo '$("#nrctrlim","#frmDadosLimiteDscChq").val("'.formataNumericos('z.zzz.zz9',$dados[14]->cdata,'.').'");';
		echo '$("#vllimite","#frmDadosLimiteDscChq").val("'.number_format(str_replace(",",".",$dados[15]->cdata),2,",",".").'");';
		echo '$("#qtdiavig","#frmDadosLimiteDscChq").val("'.formataNumericos('zzz.zz9',$dados[16]->cdata,'.').' dias");';
		echo '$("#cddlinha","#frmDadosLimiteDscChq").val("'.formataNumericos('zz9',$dados[17]->cdata,'.').'");';
		echo '$("#cddlinh2","#frmDadosLimiteDscChq").val("'.$dados[2]->cdata.'");';
		echo '$("#dsramati","#frmDadosLimiteDscChq").val("'.$dados[4]->cdata.'");';
		echo '$("#vlmedtit","#frmDadosLimiteDscChq").val("'.number_format(str_replace(",",".",$dados[5]->cdata),2,",",".").'");';
		echo '$("#vlfatura","#frmDadosLimiteDscChq").val("'.number_format(str_replace(",",".",$dados[6]->cdata),2,",",".").'");';
		echo '$("#dtcancel","#frmDadosLimiteDscChq").val("'.$dados[18]->cdata.'");';
		echo '$("#dsobserv","#frmDadosLimiteDscChq").val("'.str_replace(chr(13),"\\n",str_replace(chr(10),"\\r",$dados[12]->cdata)).'");';
		echo '$("#antnrctr","#frmDadosLimiteDscChq").val("'.formataNumericos('zzz.zz9',$dados[14]->cdata,'.').'");';
        // PRJ 438 - Sprint 14 - Incluido nivel de risco e taxa
		echo '$("#nivrisco","#frmDadosLimiteDscChq").val("'.$dados[34]->cdata.'");';
		echo '$("#txmensal","#frmDadosLimiteDscChq").val("'.$dados[35]->cdata.'");';
		
		// Pj470 - SM2 -- Mateus Zimmermann -- Mouts
		echo 'aux_vllimite_anterior = "'.number_format(str_replace(",",".",$dados[15]->cdata),2,",",".").'";';
		// Fim Pj470 - SM2
		// [020]
		/*
		 *
		 * Preencher os dados da tela de demonstração
		 *
		 */
		echo '$("#demoNivrisco","#divDscChq_Demonstracao").val( $("#nivrisco","#frmDadosLimiteDscChq").val() );';
		echo '$("#demoNrctrlim","#divDscChq_Demonstracao").val("'.formataNumericos('z.zzz.zz9',$dados[14]->cdata,'.').'");';
		echo '$("#demoVllimite","#divDscChq_Demonstracao").val("'.number_format(str_replace(",",".",$dados[15]->cdata),2,",",".").'");';

		$cdlinhaConcat = formataNumericos('zz9',$dados[17]->cdata,'.') . ' ' . $dados[2]->cdata;
		echo '$("#demoCddlinha","#divDscChq_Demonstracao").val("'.$cdlinhaConcat.'");';

		echo '$("#demoTxmensal","#divDscChq_Demonstracao").val("'.number_format(str_replace(",",".",$dados[0]->cdata),6,",",".").'%");';
		echo '$("#demoQtdiavig","#divDscChq_Demonstracao").val("'.formataNumericos('zzz.zz9',$dados[16]->cdata,'.').' dias");';
		// fim [020]

	}

	// Na consulta não permitir manipulação dos campos
	if ($cddopcao == "C" || $cddopcao == "E") {
		?>
		$("input[type='text']","#frmDadosLimiteDscChq").prop("disabled",true).attr("class","campoTelaSemBorda");
		$("select","#frmDadosLimiteDscChq").prop("disabled",true);
		$("textarea","#frmDadosLimiteDscChq").attr("readonly",true);	
		<? 	
	// Para demais operações, configurar máscaras para campos do formulário
	} else {
		if ($cddopcao == "A") {?>
			$("#nrctrlim","#frmDadosLimiteDscChq").prop("disabled",true).attr("class","campoTelaSemBorda");<? 
		} 
	?>
	// Dados do Limite	
	$("#nrctrlim","#frmDadosLimiteDscChq").setMask("INTEGER","z.zzz.zz9","");
	$("#vllimite","#frmDadosLimiteDscChq").setMask("DECIMAL","zzz.zzz.zz9,99","");
	$("#vlmedtit","#frmDadosLimiteDscChq").setMask("DECIMAL","z.zzz.zz9,99","");
	$("#vlfatura","#frmDadosLimiteDscChq").setMask("DECIMAL","z.zzz.zz9,99","");
	$("#dsramati","#frmDadosLimiteDscChq").setMask("STRING","40",charPermitido(),"");


	<? 
	} 
	?>

	// Atribui eventos para botões do formulário
	$("#btnVoltarLimite","#divBotoesLimite").unbind("click").bind("click",function() {
		
		if(executandoProdutos){
			
			encerraRotina(true);
			
		}else{
			
		voltaDiv(3,2,4,"DESCONTO DE CHEQUES - LIMITE");
			
		}
		return false;
		
	});
	
	$("#btnContinuarLimite","#divBotoesLimite").unbind("click").bind("click",function() {
		
		if(parseInt($("#vllimite","#frmDadosLimiteDscChq").val().replace(",","")) == 0){
			showError("error","Valor do limite deve ser maior que zero.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
		
		<? if ($cddopcao == "C") { ?>
      <? if ($dados[33]->cdata > 0) { ?>      
      abrirTelaGAROPC("C");
      blockBackground(parseInt($("#divRotina").css("z-index")));
      <? } else { ?>
  		// PRJ 438 - Sprint 14 - Removido a tela Rendas
		continuarRating("divDscChq_Observacao;divBotoesObs","divDscChq_Limite;divBotoesLimite");
      <? } ?>
		<? } else { ?>
			aux_inconfir = 1; 
			aux_inconfi2 = 11; 
			aux_inconfi3 = ""; 
			aux_inconfi4 = 71; 
			aux_inconfi5 = 30;
			aux_inconfi6 = 51;
			validaValorProduto(nrdconta, 36, $("#vllimite","#frmDadosLimiteDscChq").val().replace('.','').replace(',','.'),"validaLimiteDscChq(\"<? echo $cddopcao; ?>\",1,11,30);","divRotina");
		<? } ?>
		return false;
	});
	
  $("#btnVoltarGAROPC","#divBotoesGAROPC").unbind("click").bind("click",function() {
    $("#divUsoGAROPC").empty();
    $("#divFormGAROPC").empty();
    $("#frmDadosLimiteDscChq").css("width", 515);
    dscShowHideDiv("divDscChq_Limite;divBotoesLimite", "divFormGAROPC;divBotoesGAROPC");
		return false;
	});
	
  $("#btnContinuarGAROPC","#divBotoesGAROPC").unbind("click").bind("click",function() {
	// PRJ 438 - Sprint 14 - Removido a tela Rendas
  	gravarGAROPC('idcobert','frmDadosLimiteDscChq','continuarRating("divDscChq_Observacao;divBotoesObs","divFormGAROPC;divBotoesGAROPC","","$(\'#frmDadosLimiteDscChq\').css(\'width\', 540);");$("#frmDadosLimiteDscChq").css("width", 515);dscShowHideDiv("divDscChq_Observacao;divBotoesObs","divFormGAROPC;divBotoesGAROPC");');
    return false;
	});
  
	$("#btnVoltarObservacao","#divBotoesObs").unbind("click").bind("click",function() {
		// PRJ 438 - Sprint 14 - Removido a tela Rendas
		if (habrat == 'N') {
			dscShowHideDiv("divDadosRating","divDscChq_Observacao;divBotoesObs");
			return false;
		} else {
    <? if ($cddopcao == "C") { ?>
      <? if ($dados[33]->cdata > 0) { ?>
	            dscShowHideDiv('divFormGAROPC;divBotoesGAROPC','divDscChq_Observacao;divBotoesObs');
        $("#frmDadosLimiteDscChq").css("width", 540);
      <? } else { ?>
			    dscShowHideDiv('divDscChq_Limite;divBotoesLimite','divDscChq_Observacao;divBotoesObs');
      <? } ?>      
    <? } else if ($cddopcao == "A" || $cddopcao == "I") { ?>
	          dscShowHideDiv('divFormGAROPC;divBotoesGAROPC','divDscChq_Observacao;divBotoesObs');
      $("#frmDadosLimiteDscChq").css("width", 540);
    <? } else { ?>
			  dscShowHideDiv('divDscChq_Limite;divBotoesLimite','divDscChq_Observacao;divBotoesObs');
    <? } ?>
		return false;
        } 
	});
	
	$("#btnContinuarObservacao","#divBotoesObs").unbind("click").bind("click",function() {

		if(nrAvalistas == 0 && operacao == 'C'){
			$("#frmDadosLimiteDscChq").css("width", 525);
			dscShowHideDiv("divDscChq_Demonstracao;divBotoesDemo","divDscChq_Observacao;divBotoesObs");
			preencherDemonstracao();
			return false;
		}

		if(nrAvalistas > 0){
			atualizarCamposTelaAvalistas();
			}

	    $("#frmDadosLimiteDscChq").css("width", 525);
		dscShowHideDiv("divDscChq_Avalistas;divBotoesAval","divDscChq_Observacao;divBotoesObs");
		return false;
	});
	
	$("#btnVoltarDemonstracao","#divBotoesDemo").unbind("click").bind("click",function() {

		if(nrAvalistas == 0 && operacao == 'C'){
			$("#frmDadosLimiteDscChq").css("width", 515);
			dscShowHideDiv("divDscChq_Observacao;divBotoesObs","divDscChq_Demonstracao;divBotoesDemo");
			return false;
		}

	 	abrirTelaDemoDescontoCheque(false);
		return false;
	});
	
	$("#btnVoltarDemonstracaoE","#divBotoesDemo").unbind("click").bind("click",function() {
		voltaDiv(3,2,4,"DESCONTO DE CHEQUES - LIMITE");
		return false;
	});
	
	$("#btnConcluirLimiteE","#divBotoesDemo").unbind("click").bind("click",function() {

        showConfirmacao('Deseja confirmar opera&ccedil&atildeo?','Confirma&ccedil&atildeo - Aimaro','confirmaNovoLimite();voltaDiv(3,2,4,"DESCONTO DE CHEQUES - LIMITE");','metodoBlock();','sim.gif','nao.gif');
		return false;
	});
	
	if (operacao != 'C') {
		$("#btnCancelarLimite","#divBotoesDemo").unbind("click").bind("click",function() {
			voltaDiv(3,2,4,"DESCONTO DE CHEQUES - LIMITE");
			return false;
		});
	}
	
	$("#btnConcluirLimite","#divBotoesDemo").unbind("click").bind("click",function() {
		if (operacao == 'C') {
			voltaDiv(3,2,4,"DESCONTO DE CHEQUES - LIMITE");
		} else {
			buscaGrupoEconomico();
		}
		return false;
	});

	$('#nrctrlim','#frmDadosLimiteDscChq').focus();
	
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>