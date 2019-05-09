<? 
/*!
 * FONTE        : form_limite_credito.php
 * CRIAÇÃO      : Rodolpho Telmo(DB1)
 * DATA CRIAÇÃO : 29/04/2011 
 * OBJETIVO     : Formulário da rotina LIMITE DE CREDITO
 
 * ALTERAÇÕES   : 23/11/2012  - Inicializado as variáveis aux_inconfir, aux_inconfi2 e passado
								as mesmas como parametro da função validarNovoLimite
							    (Adriano).

                  15/01/2014 - Implementacoes referentes ao projeto melhoria alteracao
                               de proposta SD237152(Tiago/Gielow)
							   
				  13/02/2015 - Alterado botao continuar por alterar (Lucas R./Gielow)
				  
				  07/04/2015 - Consultas automatizadas (Jonata-RKAM)
				
				  13/04/2018 - Incluida chamada da function validaAdesaoValorProduto. PRJ366 (Lombardi)
				
				  26/11/2018 - Alterações PJ438. Rubens Lima (Mouts)
				  30/11/2018 - prj 438 - Bruno Luiz Katzjarowski - Mout's - Preencher valores da dadosRenda na tela de novoLimite
				
 */	
	/*
		Puxar valores de renda
		Bruno - prj 438 - sprint 7 - novo limite
		PF: LIMI0001.pc_busca_dados_lim_pf
		PJ:  LIMI0001.pc_busca_dados_lim_pj

		Parametros: nrconta
	*/

	$xml  = "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	$proc = "";
	if($inpessoa == '1'){
		$proc = "BUSCA_DADOS_LIM_PF";
	}else if($inpessoa == '2' || $inpessoa == '3'){
		$proc = "BUSCA_DADOS_LIM_PJ";
	}
	$xmlResultDadosConta = mensageria($xml, "ATENDA", $proc, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlDadosConta = new SimpleXMLElement($xmlResultDadosConta);

	/* 
		public 'vlsaltit' => string '  1.500,00 ' (length=11) -> salario titular
		public 'vlrentit' => string '    210,00 ' (length=11) -> Outras rendas
		public 'vlrencjg' => string '       ,00 ' (length=11) -> renda do conjuge
		public 'idpgtalg' => string 'N' (length=1) -> se ele paga aluguel ou não
		public 'vlalugue' => string '  1.500,00 ' -> valor do aluguel
 */	
	if(isset($xmlDadosConta->inf)){
		$vlsalari = $xmlDadosConta->inf[0]->{'vlsaltit'};
		$vloutras = $xmlDadosConta->inf[0]->{'vlrentit'};
		$vlsalcon = $xmlDadosConta->inf[0]->{'vlrencjg'};
		$vlalugue = $xmlDadosConta->inf[0]->{'vlalugue'};
	}
	
	
?>

<fieldset class="fsLimiteCredito">

	<legend><? echo utf8ToHtml('Dados da Solicitação') ?></legend>			

	<!-- PRJ 438 - Sprint 7 -->
	<label for="nivrisco"><? echo utf8ToHtml('Nível de Risco:') ?></label>
	<input name="nivrisco" id="nivrisco" type="text" value="<? echo $nivrisco; ?>" />
	<br />

	<label for="nrctrlim"><? echo utf8ToHtml('Número do Contrato:') ?></label>	
	<input name="nrctrlim" id="nrctrlim" type="text" value="<? echo $nrctrlim; ?>" />
	<br>
	
	<label for="vllimite"><? echo utf8ToHtml('Valor do Limite de Crédito:') ?></label>	
	<input name="vllimite" type="text" id="vllimite" value="<?php echo number_format(str_replace(",",".",$vllimite),2,",","."); ?>" />
	<br />
	
	<label for="cddlinha"><? echo utf8ToHtml('Linha de Crédito:') ?></label>
	<input name="cddlinha" id="cddlinha" type="text" value="<? echo $cddlinha; ?>" />
	<a class="lupa"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<input name="dsdlinha" type="text" id="dsdlinha"  value="<? echo $dsdlinha; ?>" />
	<br />
	
	<!-- PRJ 438 - Sprint 7 -->
	<label for="dsdtxfix"> <? echo utf8ToHtml('Taxa:') ?></label>
	<input name="dsdtxfix" id="dsdtxfix" type="text" value="<? echo $dsdtxfix; ?>" />
	<br>
	
	<!-- PRJ 438 - Sprint 7 -->
	<label for="inconcje"><? echo utf8ToHtml('Co-Responsável:') ?></label>
	<input name="inconcje" id="inconcje_1" type="radio" class="radio" value="1" <?php echo $inconcje == 1 ? 'checked' : '' ?> />
	<label for="flgYes" class="radio" >Sim</label>
	<input name="inconcje" id="inconcje_0" type="radio" class="radio" value="0" <?php echo $inconcje == 0 ? 'checked' : '' ?> />
	<label for="flgNo" class="radio"><? echo utf8ToHtml('Não') ?></label>
	
	<input name="vlsalari" class="moeda" id="vlsalari" type="hidden" value="<? echo $vlsalari; ?>" />
	<input name="vlsalcon" class="moeda" id="vlsalcon" type="hidden" value="<? echo $vlsalcon; ?>" />
	<input name="vloutras" class="moeda" id="vloutras" type="hidden" value="<? echo $vloutras; ?>" />
	<input name="vlalugue" class="moeda" id="vlalugue" type="hidden" value="<? echo $vlalugue; ?>" />
	<input name="idcobert" id="idcobert" type="hidden" value="0" />
	
	<br style="clear:both" />	
	
</fieldset>		

<div id="divBotoes">
	
	
	<? if ($cddopcao == 'N') { // Se for novo limite ou alteracao ?>

		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="<? echo $fncPrincipal; ?>return false;">
		
		<? if ($flgProposta == "true") { ?>	
			<input type="image" src="<? echo $UrlImagens; ?>botoes/imprimir_contrato.gif" 
			onClick="verificaEnvioEmail(2,'<? echo $flgimpnp; ?>',<? echo $nrctrpro; ?>);return false;">
			
			<!-- bruno - prj - 438 - sprint 7 - fluxo novo limite -->
			<!-- <input type="image" src="<? //echo $UrlImagens; ?>botoes/excluir_novo_limite.gif" 
			onClick="showConfirmacao('Deseja excluir o novo ' + strTitRotinaLC + '?','Confirma&ccedil;&atilde;o - Aimaro','excluirNovoLimite()',metodoBlock,'sim.gif','nao.gif');return false;"> -->
			 
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" 
			onClick="aux_inconfir = 1; aux_inconfi2 = 30; validaAdesaoValorProduto('validarAlteracaoLimite('+aux_inconfir+','+aux_inconfi2+',\'<?php echo $flgimpnp; ?>\');'); return false;">
		<? } else { ?>
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="aux_inconfir = 1; aux_inconfi2 = 30; validaAdesaoValorProduto('validarNovoLimite('+aux_inconfir+','+aux_inconfi2+');'); return false;">
		<? } ?>	
	
	<? } else if ($cddopcao == 'R') { // Se for renovacao ?>

		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="acessaTela('@');return false;">
		<input type="image" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="showConfirmacaoRenovar(); return false;"> 

	<? } else { // Se for consulta 
			if ($nrctrlim > 0)  { // Se tiver contrato ou proposta ?>
				<!-- bruno - prj - 438 - sprint 7 - tela principal -->
				<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="acessaTela('@');return false;">
				<input type="image" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="abrirGaropc(); return false;"> 
			<? } ?>
	<? } ?>
	
</div>