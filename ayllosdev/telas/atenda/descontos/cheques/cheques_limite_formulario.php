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
 * 015: [13/04/2018] Lombardi     (CECRED)   : Incluida chamada da function validaValorProduto. PRJ366
 * 016: [04/06/2019] Mateus Z      (Mouts)   : Alteração para chamar tela de autorização quando alterar valor. PRJ 470 SM2
 * 017: [29/03/2019] Luiz Otávio (AMCOM)     : Retirado etapa Rating - P450
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
		
			<legend>Dados do Limite</legend>
			
			<label for="nrctrlim"><? echo utf8ToHtml('Contrato:') ?></label>
			<input type="text" name="nrctrlim" id="nrctrlim" value="0" class="campoTelaSemBorda" disabled>
			<br />
			
			<label></label>
			<br />
			
			<label for="vllimite"><? echo utf8ToHtml('Valor do Limite:') ?></label>
			<input type="text" name="vllimite" id="vllimite" value="0,00" class="campo">
			
			<label for="qtdiavig"><? echo utf8ToHtml('Vigência:') ?></label>
			<input type="text" name="qtdiavig" id="qtdiavig" value="0" class="campoTelaSemBorda" disabled>
			<br />
			
			<label for="cddlinha"><? echo utf8ToHtml('Linha de descontos:') ?></label>
			<input type="text" name="cddlinha" id="cddlinha" value="0" class="campo">
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input type="text" name="cddlinh2" id="cddlinh2" value="" class="campoTelaSemBorda" disabled>
			<br />
			
			<label for="txjurmor"><? echo utf8ToHtml('Juros mora:') ?></label>
			<input type="text" name="txjurmor" id="txjurmor" value="%" class="campoTelaSemBorda" disabled>
			<br />
			
			<label for="txdmulta"><? echo utf8ToHtml('Taxa de multa:') ?></label>
			<input type="text" name="txdmulta" id="txdmulta" value="0,000000%" class="campoTelaSemBorda" disabled>
			<br />
			
			<label for="dsramati"><? echo utf8ToHtml('Ramo de Atividade:') ?></label>
			<input type="text" name="dsramati" id="dsramati" value="" class="campo">
			<br />
			
			<label for="vlmedtit"><? echo utf8ToHtml('Valor médio dos cheques:') ?></label>
			<input type="text" name="vlmedtit" id="vlmedtit" value="0,00" class="campo">
			<br />
			
			<label for="vlfatura"><? echo utf8ToHtml('Faturamento mensal:') ?></label>
			<input type="text" name="vlfatura" id="vlfatura" value="0,00" class="campo">
			
			<label for="dtcancel"><? echo utf8ToHtml('Data de cancelamento:') ?></label>
			<input type="text" name="dtcancel" id="dtcancel" value="" class="campoTelaSemBorda" disabled>
			
		</fieldset>
				
	</div>
	
  <div id="divUsoGAROPC"></div>
  
  <div id="divFormGAROPC"></div>
	
	<div id="divDscChq_Renda">
	
		<fieldset>
		
			<legend>Rendas</legend>
								
				<label for="lbrendas"><? echo utf8ToHtml('Rendas:') ?></label>
				<label for="vlsalari"><? echo utf8ToHtml('Salário:') ?></label>
				<input type="text" name="vlsalari" id="vlsalari" value="0,00" class="campo">
				
				<label for="vlsalcon"><? echo utf8ToHtml('Cônjuge:') ?></label>
				<input type="text" name="vlsalcon" id="vlsalcon" value="0,00" class="campo">
				<br />
				
				<label for="vloutras"><? echo utf8ToHtml('Outras:') ?></label>
				<input type="text" name="vloutras" id="vloutras" value="0,00" class="campo">
				<br />
				<label class="rotulo"></label>
				<br />
				
				<label for="dsdbens1"><? echo utf8ToHtml('Bens:') ?></label>
				<input type="text" name="dsdbens1" id="dsdbens1" value="" class="campo">
				<br />
				
				<label for="dsdbens2"><? echo utf8ToHtml('') ?></label>
				<input type="text" name="dsdbens2" id="dsdbens2" value="" class="campo">
								
		</fieldset>
		
	</div>
	
	<div id="divDscChq_Observacao">
	
		<fieldset>
		
			<legend><? echo utf8ToHtml('Observações:') ?></legend>
			
			<textarea name="dsobserv" id="dsobserv" style="width: 450px;" rows="5" maxlength="953" ></textarea>
						
		</fieldset>
				
	</div>
	
	<div id="divDscChq_Avalistas" class="condensado" >
		<? 
			// ALTERAÇÃO 001: Substituido formulário antigo pelo include				
			include('../../../../includes/avalistas/form_avalista.php'); 
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

<div id="divBotoesRenda">

	<input type="image" id="btnVoltarRendas" name="btnVoltarRendas" src="<? echo $UrlImagens; ?>botoes/voltar.gif" />
	<input type="image" id="btnContinuarRendas" name="btnContinuarRendas" src="<? echo $UrlImagens; ?>botoes/continuar.gif" />
	
</div>

<div id="divBotoesObs" >

	<input type="image" id="btnVoltarObservacao" name="btnVoltarObservacao" src="<? echo $UrlImagens; ?>botoes/voltar.gif" />
	<input type="image" id="btnContinuarObservacao" name="btnContinuarObservacao" src="<? echo $UrlImagens; ?>botoes/continuar.gif" />

</div>

<div id="divBotoesAval">	
		
	<input type="image" id="btnVoltarAvalistas" name="btnVoltarAvalistas" src="<? echo $UrlImagens; ?>botoes/voltar.gif">
	<? if ($cddopcao <> "C") { ?>
		<input type="image" id="btnCancelarLimite" name="btnCancelarLimite" src="<? echo $UrlImagens; ?>botoes/cancelar.gif">
	<? } ?>
	<input type="image" id="btnConcluirLimite" name="btnConcluirLimite" src="<? echo $UrlImagens; ?>botoes/concluir.gif">
	
</div>

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

	formataLayout('frmDadosLimiteDscChq');
	
	operacao = '<? echo $cddopcao; ?>';
	
	dscShowHideDiv("divOpcoesDaOpcao3;divDscChq_Limite;divBotoesLimite","divBotoesGAROPC;divBotoesRenda;divBotoesObs;divBotoesAval;divOpcoesDaOpcao2;divDscChq_Renda;divDscChq_Observacao;divDscChq_Avalistas");
		
	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE CHEQUES - LIMITE - <? if ($cddopcao == "A") { echo "ALTERAR"; } elseif ($cddopcao == "C") { echo "CONSULTAR"; } else { echo "INCLUIR"; } ?>");

	<? 
	// Alimentar campos do formulário para gerenciar limite
	if ($cddopcao == "I") { 
		echo '$("#qtdiavig","#frmDadosLimiteDscChq").val("'.formataNumericos('zzz.zz9',$dados[4]->cdata,'.').' dias");';
		echo '$("#txdmulta","#frmDadosLimiteDscChq").val("'.number_format(str_replace(",",".",$dados[11]->cdata),6,",",".").'%");';
	} else { 
		echo '$("#nrctrlim","#frmDadosLimiteDscChq").val("'.formataNumericos('z.zzz.zz9',$dados[14]->cdata,'.').'");';
		echo '$("#vllimite","#frmDadosLimiteDscChq").val("'.number_format(str_replace(",",".",$dados[15]->cdata),2,",",".").'");';
		echo '$("#qtdiavig","#frmDadosLimiteDscChq").val("'.formataNumericos('zzz.zz9',$dados[16]->cdata,'.').' dias");';
		echo '$("#cddlinha","#frmDadosLimiteDscChq").val("'.formataNumericos('zz9',$dados[17]->cdata,'.').'");';
		echo '$("#cddlinh2","#frmDadosLimiteDscChq").val("'.$dados[2]->cdata.'");';
		echo '$("#txjurmor","#frmDadosLimiteDscChq").val("'.number_format(str_replace(",",".",$dados[3]->cdata),6,",",".").'%");';
		echo '$("#txdmulta","#frmDadosLimiteDscChq").val("'.number_format(str_replace(",",".",$dados[0]->cdata),6,",",".").'%");';
		echo '$("#dsramati","#frmDadosLimiteDscChq").val("'.$dados[4]->cdata.'");';
		echo '$("#vlmedtit","#frmDadosLimiteDscChq").val("'.number_format(str_replace(",",".",$dados[5]->cdata),2,",",".").'");';
		echo '$("#vlfatura","#frmDadosLimiteDscChq").val("'.number_format(str_replace(",",".",$dados[6]->cdata),2,",",".").'");';
		echo '$("#dtcancel","#frmDadosLimiteDscChq").val("'.$dados[18]->cdata.'");';
		echo '$("#vlsalari","#frmDadosLimiteDscChq").val("'.number_format(str_replace(",",".",$dados[8]->cdata),2,",",".").'");';
		echo '$("#vlsalcon","#frmDadosLimiteDscChq").val("'.number_format(str_replace(",",".",$dados[9]->cdata),2,",",".").'");';
		echo '$("#vloutras","#frmDadosLimiteDscChq").val("'.number_format(str_replace(",",".",$dados[7]->cdata),2,",",".").'");';
		echo '$("#dsdbens1","#frmDadosLimiteDscChq").val("'.trim($dados[10]->cdata).'");';
		echo '$("#dsdbens2","#frmDadosLimiteDscChq").val("'.trim($dados[11]->cdata).'");';	
		echo '$("#dsobserv","#frmDadosLimiteDscChq").val("'.str_replace(chr(13),"\\n",str_replace(chr(10),"\\r",$dados[12]->cdata)).'");';
		echo '$("#antnrctr","#frmDadosLimiteDscChq").val("'.formataNumericos('zzz.zz9',$dados[14]->cdata,'.').'");';
		// Pj470 - SM2 -- Mateus Zimmermann -- Mouts
		echo 'aux_vllimite_anterior = "'.number_format(str_replace(",",".",$dados[15]->cdata),2,",",".").'";';
		// Fim Pj470 - SM2
	}

	// Na consulta não permitir manipulação dos campos
	if ($cddopcao == "C") {
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
	$("#cddlinha","#frmDadosLimiteDscChq").setMask("INTEGER","zz9","");
	$("#vlmedtit","#frmDadosLimiteDscChq").setMask("DECIMAL","z.zzz.zz9,99","");
	$("#vlfatura","#frmDadosLimiteDscChq").setMask("DECIMAL","z.zzz.zz9,99","");
	$("#dsramati","#frmDadosLimiteDscChq").setMask("STRING","40",charPermitido(),"");

	// Rendas
	$("#vloutras","#frmDadosLimiteDscChq").setMask("DECIMAL","zzz.zzz.zz9,99","");
	$("#vlsalari","#frmDadosLimiteDscChq").setMask("DECIMAL","zzz.zzz.zz9,99","");
	$("#vlsalcon","#frmDadosLimiteDscChq").setMask("DECIMAL","zzz.zzz.zz9,99","");
	$("#dsdbens1","#frmDadosLimiteDscChq").setMask("STRING","60",charPermitido(),"");
	$("#dsdbens2","#frmDadosLimiteDscChq").setMask("STRING","60",charPermitido(),"");

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
			dscShowHideDiv("divDscChq_Renda;divBotoesRenda","divDscChq_Limite;divBotoesLimite");
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
    gravarGAROPC('idcobert','frmDadosLimiteDscChq','dscShowHideDiv("divDscChq_Renda;divBotoesRenda","divFormGAROPC;divBotoesGAROPC", "");$("#frmDadosLimiteDscChq").css("width", 515);bloqueiaFundo($("#divDscChq_Renda"));');
    return false;
	});
  
	$("#btnVoltarRendas","#divBotoesRenda").unbind("click").bind("click",function() {
    <? if ($cddopcao == "C") { ?>
      <? if ($dados[33]->cdata > 0) { ?>
        dscShowHideDiv('divFormGAROPC;divBotoesGAROPC','divDscChq_Renda;divBotoesRenda');
        $("#frmDadosLimiteDscChq").css("width", 540);
      <? } else { ?>
		dscShowHideDiv('divDscChq_Limite;divBotoesLimite','divDscChq_Renda;divBotoesRenda');
      <? } ?>      
    <? } else if ($cddopcao == "A" || $cddopcao == "I") { ?>
      dscShowHideDiv('divFormGAROPC;divBotoesGAROPC','divDscChq_Renda;divBotoesRenda');
      $("#frmDadosLimiteDscChq").css("width", 540);
    <? } else { ?>
		dscShowHideDiv('divDscChq_Limite;divBotoesLimite','divDscChq_Renda;divBotoesRenda');
    <? } ?>
		return false;
	});
	
	$("#btnContinuarRendas","#divBotoesRenda").unbind("click").bind("click",function() {
		<? if ($cddopcao == "A") { ?>
			// Rating Antigo
			if (habrat == 'N') {
				$('#divBotoesRenda').css('display','none');
				// Pj470 - SM2 -- Mateus Zimmermann -- Mouts 
				var aux_vllimite = normalizaNumero($("#vllimite","#frmDadosLimiteDscChq").val());
				aux_vllimite_anterior = normalizaNumero(aux_vllimite_anterior);
				var aux_fncRatingSuccess = '';
				if(aux_vllimite_anterior != aux_vllimite){
					aux_fncRatingSuccess = "chamarImpressaoChequeLimite();";
				}else{
					aux_fncRatingSuccess = "carregaLimitesCheques();";
				}
				informarRating("divDscChq_Renda","dscShowHideDiv('divDscChq_Observacao;divBotoesObs','divDadosRating;divBotoesRenda')","dscShowHideDiv('divDscChq_Renda;divBotoesRenda','divDadosRating');", aux_fncRatingSuccess);
				// Fim Pj470 - SM2
			// Rating Novo
			} else {
				$("#divDscChq_Renda").css("display","none");
				// Pj470 - SM2 -- Mateus Zimmermann -- Mouts 
				var aux_vllimite = normalizaNumero($("#vllimite","#frmDadosLimiteDscChq").val());
				aux_vllimite_anterior = normalizaNumero(aux_vllimite_anterior);
				var aux_fncRatingSuccess = '';
				if(aux_vllimite_anterior != aux_vllimite){
					aux_fncRatingSuccess = "chamarImpressaoChequeLimite();";
				}else{
					aux_fncRatingSuccess = "carregaLimitesCheques();";
				}

				dscShowHideDiv('divDscChq_Observacao;divBotoesObs','divDadosRating;divBotoesRenda');
				// informarRating("divDscChq_Renda","dscShowHideDiv('divDscChq_Observacao;divBotoesObs','divDadosRating;divBotoesRenda')","dscShowHideDiv('divDscChq_Renda;divBotoesRenda','divDadosRating');", aux_fncRatingSuccess);
				// Fim Pj470 - SM2
			}
			// Fim Rating
		<? } elseif ($cddopcao == "C") { ?>
			// Rating Antigo
			if (habrat == 'N') {
				$('#divBotoesRenda').css('display','none');
				informarRating("divDscChq_Renda","dscShowHideDiv('divDscChq_Observacao;divBotoesObs','divDadosRating;divBotoesRenda')","dscShowHideDiv('divDscChq_Renda;divBotoesRenda','divDadosRating');","carregaLimitesCheques()");
			// Rating Novo
			} else {
				$("#divDscChq_Renda").css("display","none");
				dscShowHideDiv('divDscChq_Observacao;divBotoesObs','divDadosRating;divBotoesRenda');
			}
			// Fim Rating
		<? } else { ?>
			// Rating Antigo
			if (habrat == 'N') {
				$('#divBotoesRenda').css('display','none');
				//prj 470 - tela autorizacao
				informarRating("divDscChq_Renda",
							   "dscShowHideDiv('divDscChq_Observacao;divBotoesObs','divDadosRating;divBotoesRenda')",
							   "dscShowHideDiv('divDscChq_Renda;divBotoesRenda','divDadosRating');",
							   "chamarImpressaoChequeLimite()");
			// Rating Novo
			} else {
				$("#divDscChq_Renda").css("display","none");
				dscShowHideDiv('divDscChq_Observacao;divBotoesObs','divDadosRating;divBotoesRenda');
			}
			// Fim Rating
		<? } ?>
		return false;
	});
	
	$("#btnVoltarObservacao","#divBotoesObs").unbind("click").bind("click",function() {
		if (habrat == 'N') {
			dscShowHideDiv("divDadosRating","divDscChq_Observacao;divBotoesObs");
			return false;
		} else {
			dscShowHideDiv("divDscChq_Renda;divBotoesRenda","divDscChq_Observacao;divBotoesObs");
			return false;
        	} 
	});
	
	$("#btnContinuarObservacao","#divBotoesObs").unbind("click").bind("click",function() {
    $("#frmDadosLimiteDscChq").css("width", 525);
		dscShowHideDiv("divDscChq_Avalistas;divBotoesAval","divDscChq_Observacao;divBotoesObs");
		return false;
	});
	
	$("#btnVoltarAvalistas","#divBotoesAval").unbind("click").bind("click",function() {
		$("#frmDadosLimiteDscChq").css("width", 515);
		dscShowHideDiv("divDscChq_Observacao;divBotoesObs","divDscChq_Avalistas;divBotoesAval");
		return false;
	});
	
	if (operacao != 'C') {
		$("#btnCancelarLimite","#divBotoesAval").unbind("click").bind("click",function() {
			voltaDiv(3,2,4,"DESCONTO DE CHEQUES - LIMITE");
			return false;
		});
	}
	
	$("#btnConcluirLimite","#divBotoesAval").unbind("click").bind("click",function() {
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