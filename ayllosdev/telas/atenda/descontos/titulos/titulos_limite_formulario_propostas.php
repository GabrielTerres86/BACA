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
 * 015: [29/05/2019] Luiz Otávio OM (AMCOM) : Adicionado Etapa Rating para Cooperatova Ailos (3)
 * 014: [04/06/2019] Mateus Z  (Mouts) : Alteração para chamar tela de autorização quando alterar valor. PRJ 470 - SM2
 */
define('cooperativaCetralAilosEtapaRating', 3);
?>
<form action="" name="frmDadosLimiteDscTit" id="frmDadosLimiteDscTit" onSubmit="return false;">

	<input type="hidden" id="idcobert" value="<?php echo $dados[30]->cdata; ?>" />

	<div id="divDscTit_Limite">
	
		<fieldset>
		
			<legend>Dados do Limite</legend>
			
			<label for="nrctrlim"><? echo utf8ToHtml('Contrato:') ?></label>
			<input type="text" name="nrctrlim" id="nrctrlim" value="0" class="campo" disabled>
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
			
			<label for="txdmulta"><? echo utf8ToHtml('taxa de multa:') ?></label>
			<input type="text" name="txdmulta" id="txdmulta" value="0,000000%" class="campoTelaSemBorda" disabled>
			<br />
			
			<label for="dsramati"><? echo utf8ToHtml('Ramo de Atividade:') ?></label>
			<input type="text" name="dsramati" id="dsramati" value="" class="campo">
			<br />
			
			<label for="vlmedtit"><? echo utf8ToHtml('Valor médio dos títulos:') ?></label>
			<input type="text" name="vlmedtit" id="vlmedtit" value="0,00" class="campo">
			<br />
			
			<label for="vlfatura"><? echo utf8ToHtml('Faturamento mensal:') ?></label>
			<input type="text" name="vlfatura" id="vlfatura" value="0,00" class="campo">
			
		</fieldset>
		
	</div>
	
  <div id="divUsoGAROPC"></div>
  
  <div id="divFormGAROPC"></div>
	
	<div id="divDscTit_Renda">
	
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
	
	<div id="divDscTit_Observacao">
	
		<fieldset>
		
			<legend><? echo utf8ToHtml('Observações:') ?></legend>
			<textarea name="dsobserv" id="dsobserv" style="width: 450px;" rows="5" maxlength="953"></textarea>
						
		</fieldset>
				
	</div>
	
	<div id="divDscTit_Avalistas" class="condensado" >
	
		<? 	// ALTERAÇÃO 001: Substituido formulário antigo pelo include				
			include('../../../../includes/avalistas/form_avalista.php'); 
		?>
		
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

<div id="divBotoesRenda">
		
	<input type="image" id="btnVoltarRendas" name="btnVoltarRendas" src="<? echo $UrlImagens; ?>botoes/voltar.gif" />
	<input type="image" id="btnContinuarRendas" name="btnContinuarRendas" src="<? echo $UrlImagens; ?>botoes/continuar.gif" />
	
</div>

<div id="divBotoesObs" >
		
	<input type="image" id="btnVoltarObservacao" name="btnVoltarObservacao" src="<? echo $UrlImagens; ?>botoes/voltar.gif" />
	<input type="image" id="btnContinuarObservacao" name="btnContinuarObservacao" src="<? echo $UrlImagens; ?>botoes/continuar.gif" />
	
</div>

<div id="divBotoesAval">						
		
	<input type="image" id="btnVoltarAvalistas" name="btnVoltarAvalistas" src="<? echo $UrlImagens; ?>botoes/voltar.gif" />
	<? if ($cddopcao <> "C") { ?>
		   <input type="image" id="btnCancelarLimite" name="btnCancelarLimite" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" />
	<? } ?>
	<input type="image" id="btnConcluirLimite" name="btnConcluirLimite" src="<? echo $UrlImagens; ?>botoes/concluir.gif" />
			
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

	formataLayout('frmDadosLimiteDscTit');

	operacao = '<? echo $cddopcao; ?>';
	
	dscShowHideDiv("divOpcoesDaOpcao3;divDscTit_Limite;divBotoesLimite","divBotoesGAROPC;divBotoesRenda;divBotoesObs;divBotoesAval;divOpcoesDaOpcao2;divDscTit_Renda;divDscTit_Observacao;divDscTit_Avalistas;divDscTit_Confirma");

	$("#divDscTit_Confirma").css("display","<? if ($cddopcao == "I") { echo "block"; } else { echo "none"; } ?>");
		
	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - LIMITE - <? if ($cddopcao == "A") { echo "ALTERAR"; } elseif ($cddopcao == "C") { echo "CONSULTAR"; } else { echo "INCLUIR"; } ?>");

	<? 
	// Alimentar campos do formulário para gerenciar limite
	if ($cddopcao == "I") { 
		echo '$("#qtdiavig","#frmDadosLimiteDscTit").val("'.formataNumericos('zzz.zz9',$dados[6]->cdata,'.').' dias");';
		echo '$("#txdmulta","#frmDadosLimiteDscTit").val("'.number_format(str_replace(",",".",$dados[12]->cdata),6,",",".").'%");';
	} else { 
		echo '$("#nrctrlim","#frmDadosLimiteDscTit").val("'.formataNumericos('z.zzz.zz9',$dados[14]->cdata,'.').'");';
		echo '$("#vllimite","#frmDadosLimiteDscTit").val("'.number_format(str_replace(",",".",$dados[15]->cdata),2,",",".").'");';
		echo '$("#qtdiavig","#frmDadosLimiteDscTit").val("'.formataNumericos('zzz.zz9',$dados[16]->cdata,'.').' dias");';
		echo '$("#cddlinha","#frmDadosLimiteDscTit").val("'.formataNumericos('zz9',$dados[17]->cdata,'.').'");';
		echo '$("#cddlinh2","#frmDadosLimiteDscTit").val("'.$dados[2]->cdata.'");';
		echo '$("#txdmulta","#frmDadosLimiteDscTit").val("'.number_format(str_replace(",",".",$dados[0]->cdata),6,",",".").'%");';
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
	}
	?>
	
	// Na consulta não permitir manipulação dos campos
	if (operacao == 'C') {
	
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
		$("#cddlinha",'#'+nomeForm).setMask("INTEGER","zz9","");
		$("#vlmedtit",'#'+nomeForm).setMask("DECIMAL","z.zzz.zz9,99","");
		$("#vlfatura",'#'+nomeForm).setMask("DECIMAL","zzz.zzz.zz9,99","");
		$("#dsramati",'#'+nomeForm).setMask("STRING","40",charPermitido(),"");

		// Rendas
		$("#vloutras",'#'+nomeForm).setMask("DECIMAL","zzz.zzz.zz9,99","");
		$("#vlsalari",'#'+nomeForm).setMask("DECIMAL","zzz.zzz.zz9,99","");
		$("#vlsalcon",'#'+nomeForm).setMask("DECIMAL","zzz.zzz.zz9,99","");
		$("#dsdbens1",'#'+nomeForm).setMask("STRING","60",charPermitido(),"");
		$("#dsdbens2",'#'+nomeForm).setMask("STRING","60",charPermitido(),"");

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
	
	$('#btnContinuarLimite','#divBotoesLimite').unbind('click').bind('click',function() {
		if (operacao == 'C') {
      <? if ($dados[30]->cdata > 0) { ?>
			abrirTelaGAROPC("C");
      blockBackground(parseInt($("#divRotina").css("z-index")));
      <? } else { ?>
			dscShowHideDiv('divDscTit_Renda;divBotoesRenda','divDscTit_Limite;divBotoesLimite');
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
	
  $("#btnContinuarGAROPC","#divBotoesGAROPC").unbind("click").bind("click",function() {
    gravarGAROPC('idcobert','frmDadosLimiteDscTit','dscShowHideDiv("divDscTit_Renda;divBotoesRenda","divFormGAROPC;divBotoesGAROPC", "");$("#frmDadosLimiteDscTit").css("width", 515);bloqueiaFundo($("#divDscTit_Renda"));');
    return false;
	});
	
	$('#btnVoltarRendas','#divBotoesRenda').unbind('click').bind('click',function() {
    <? if ($cddopcao == "C") { ?>
      <? if ($dados[30]->cdata > 0) { ?>
        dscShowHideDiv('divFormGAROPC;divBotoesGAROPC','divDscTit_Renda;divBotoesRenda');
        $("#frmDadosLimiteDscTit").css("width", 540);
      <? } else { ?>
		dscShowHideDiv('divDscTit_Limite;divBotoesLimite','divDscTit_Renda;divBotoesRenda');
      <? } ?>      
    <? } else if ($cddopcao == "A" || $cddopcao == "I") { ?>
      dscShowHideDiv('divFormGAROPC;divBotoesGAROPC','divDscTit_Renda;divBotoesRenda');
      $("#frmDadosLimiteDscTit").css("width", 540);
    <? } else { ?>
        dscShowHideDiv('divDscTit_Limite;divBotoesLimite','divDscTit_Renda;divBotoesRenda');
    <? } ?>
		return false;
	});
	
	$('#btnContinuarRendas','#divBotoesRenda').unbind('click').bind('click',function() {
		if (operacao == 'A') {
			$('#divBotoesRenda').css('display','none');
				fncRatingSuccess = 'carregaLimitesTitulosPropostas()';
				dscShowHideDiv('divDscTit_Observacao;divBotoesObs','divDscTit_Renda;divBotoesRenda');
		} else if (operacao == 'C') {
			$('#divBotoesRenda').css('display','none');
			<? if ($glbvars["cdcooper"] == cooperativaCetralAilosEtapaRating) { ?>
			//bruno - prj 470 - tela autorizacao
			informarRating('divDscTit_Renda',"dscShowHideDiv('divDscTit_Observacao;divBotoesObs','divDadosRating;divBotoesRenda')","dscShowHideDiv('divDscTit_Renda;divBotoesRenda','divDadosRating');","carregaLimitesTitulos()");
			<? } else { ?>
			dscShowHideDiv('divDscTit_Observacao;divBotoesObs','divDscTit_Renda;divBotoesRenda');
			<? } ?>
		} else {
			$('#divBotoesRenda').css('display','none');
			<? if ($glbvars["cdcooper"] == cooperativaCetralAilosEtapaRating) { ?>
			//bruno - prj 470 - tela autorizacao
			informarRating('divDscTit_Renda',"dscShowHideDiv('divDscTit_Observacao;divBotoesObs','divDadosRating;divBotoesRenda')","dscShowHideDiv('divDscTit_Renda;divBotoesRenda','divDadosRating');","mostraImprimirLimite(\'PROPOSTA\')");
			<? } else { ?>
			dscShowHideDiv('divDscTit_Observacao;divBotoesObs','divDscTit_Renda;divBotoesRenda');
			<? } ?>
		}
		return false;
	});
	
	$('#btnVoltarObservacao','#divBotoesObs').unbind('click').bind('click',function() {
		dscShowHideDiv('divDadosRating','divDscTit_Observacao;divBotoesObs');
		return false;
	});
	
	$('#btnContinuarObservacao','#divBotoesObs').unbind('click').bind('click',function() {
		dscShowHideDiv('divDscTit_Avalistas;divBotoesAval','divDscTit_Observacao;divBotoesObs');
		return false;
	});
	
	$('#btnVoltarAvalistas','#divBotoesAval').unbind('click').bind('click',function() {
		dscShowHideDiv('divDscTit_Observacao;divBotoesObs','divDscTit_Avalistas;divBotoesAval');
		return false;
	});
	
	if (operacao != 'C') {
		$('#btnCancelarLimite','#divBotoesAval').unbind('click').bind('click',function() {


    showConfirmacao(
        "Deseja cancelar a opera&ccedil;&atilde;o?",
        "Confirma&ccedil;&atilde;o - Aimaro",
		"carregaLimitesTitulosPropostas();",
        "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))",
        "sim.gif",
        "nao.gif");
		});
	}
	
	$('#btnConcluirLimite','#divBotoesAval').unbind('click').bind('click',function() {
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