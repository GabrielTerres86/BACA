<? 
	/*!
	 * FONTE        : form_seguro_casa.php
	 * CRIAÇÃO      : Rogério Giacomini de Almeida (GATI)
	 * DATA CRIAÇÃO : 24/09/2011 
	 * OBJETIVO     : formulário para inclusão de seguro do tipo CASA
	 * --------------
	 * ALTERAÇÕES   : 25/07/2013 - Incluído o campo Complemento no endereço. (James).
	 *
	 *				  03/07/2015 - Incluir validacao para ddvencto (Lucas Rangjetti/Thiago Rodrigues #303749)
	 * --------------
	 */

	$data = explode("/", $glbvars[dtmvtolt]);
	$dtfim = date("d/m/Y", mktime(0, 0, 0, $data[1], $data[0] + 365, $data[2]) );
	
	if ($data[0] > 28){
		$ddvencto = 28;
	}else{
		$ddvencto = $data[0];
	}
?>
<form name="frmSeguroCasa" id="frmSeguroCasa" class="formulario condensado">
	<label for="nmresseg">Seguradora:</label>
	<input name="nmresseg" id="nmresseg" type="hidden" />
	<input name="cdsegura" id="cdsegura" type="hidden" />
	<input name="tpseguro" id="tpseguro" type="hidden" value="11"/>
	
	<label for="nrctrseg">Nr Proposta:</label>
	<input name="nrctrseg" id="nrctrseg" type="text" alt=""/>
	<label for="tpplaseg">Plano:</label>
	<input name="tpplaseg" id="tpplaseg" type="text" alt="Informe o c&oacute;digo do plano."/>
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<label for="dstipseg">Tipo: Casa</label>
	
	<div id="botaoOk">
		<input type="image" id="btCarregaForm" src="<? echo $UrlImagens; ?>botoes/ok.gif" onclick="carregaFormCasa();return false;" />
	</div>
	
	<div id="part_2">
		<label for="ddpripag">Dia Primeiro Débito:</label>
		<input name="ddpripag" id="ddpripag" type="text" alt="" value="<? echo $data[0];?>" />
		<label for="ddvencto">Débito Demais Parcelas:</label>
		<input name="ddvencto" id="ddvencto" type="text" alt="" value="<? echo $ddvencto ?>"/>
		
		<br />		
		<label for="vlpreseg">Valor das Parcelas:</label>
		<input name="vlpreseg" id="vlpreseg" type="text" alt=""/>
		
		<br />
		<label for="dtinivig">Início Vigência:</label>
		<input name="dtinivig" id="dtinivig" type="text" alt="" value="<? echo $glbvars['dtmvtolt'];?>" />
		<label for="dtfimvig">Final Vigência:</label>
		<input name="dtfimvig" id="dtfimvig" type="text" alt="" value="<? echo $dtfim;?>" />
		
		<br />
		<label for="flgclabe">Cláusula Beneficiária:</label>
		<label><input name="flgclabe" value="FALSE" id="flgclabeN" type="radio" checked alt=""/>&nbsp;Não</label>
		<label><input name="flgclabe" value="TRUE" id="flgclabeS" type="radio" alt=""/>&nbsp;Sim</label>
		<label for="nmbenvid">Nome Beneficiário:</label>
		<input name="nmbenvid" id="nmbenvid" type="text" alt=""/>
		
		<br />
		<label for="dtcancel">Cancelado em:</label>
		<input name="dtcancel" id="dtcancel" type="text" alt=""/>
		<label for="dsmotcan">Motivo:</label>
		<input name="dsmotcan" id="dsmotcan" type="text" alt=""/>
		
		<br />
		<label for="locrisco">Local do Risco</label>
				
		<label for="nrcepend">CEP:</label>
		<input name="nrcepend" id="nrcepend" type="text" alt=""/>
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<label for="dsendres">Rua:</label>
		<input name="dsendres" id="dsendres" type="text" alt=""/>
		<label for="nrendere">Nº:</label>
		<input name="nrendere" id="nrendere" type="text" alt=""/>
		
		<br />
		<label for="complend">Compl.:</label>
		<input name="complend" id="complend" type="text" alt=""/>		
		
		<br />
		<label for="nmbairro">Bairro:</label>
		<input name="nmbairro" id="nmbairro" type="text" alt=""/>		
		<label for="nmcidade">Cidade:</label>
		<input name="nmcidade" id="nmcidade" type="text" alt=""/>
		<label for="cdufresd">U.F.:</label>
		<input name="cdufresd" id="cdufresd" type="text" alt=""/>
	</div>
	<div id="part_3">
		<label for="endcorre">Endereço de Correspondência</label>
		<input type="hidden" name="tipo_end_correspondencia" id="tipo_end_correspondencia">
		<label for="tpendcor">Tipo de endereço:</label>
		<label><input name="tpendcor" value="1" id="tpendcor1" type="radio" alt=""/>&nbsp;Local do Risco</label>
		<label><input name="tpendcor" value="2" id="tpendcor2" type="radio" alt=""/>&nbsp;Residencial</label>
		<label><input name="tpendcor" value="3" id="tpendcor3" type="radio" alt=""/>&nbsp;Comercial</label>		
		
		<br />
		<label for="nrcepend2">CEP:</label>
		<input name="nrcepend2" id="nrcepend2" type="text" alt=""/>		
		<label for="dsendres2">Rua:</label>
		<input name="dsendres2" id="dsendres2" type="text" alt=""/>
		<label for="nrendere2">Nº:</label>
		<input name="nrendere2" id="nrendere2" type="text" alt=""/>		
		
		<br />
		<label for="complend2">Compl.:</label>
		<input name="complend2" id="complend2" type="text" alt=""/>
		
		<br />
		<label for="nmbairro2">Bairro:</label>
		<input name="nmbairro2" id="nmbairro2" type="text" alt=""/>
		<label for="nmcidade2">Cidade:</label>
		<input name="nmcidade2" id="nmcidade2" type="text" alt=""/>
		<label for="cdufresd2">U.F.:</label>
		<input name="cdufresd2" id="cdufresd2" type="text" alt=""/>
	</div>
</form>
<div id="divBotoes">
	<input type="image" class="rotulo" id="btVoltar" 			src="<?php echo $UrlImagens; ?>botoes/voltar.gif"/>
	<input type="image" class="rotulo" id="btContinuar" 	  	src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="validaSeguroGeral('<? echo $operacao;?>', 1); return false;" />
	<input type="image" class="rotulo" id="btContinuarSalvar" 	src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="validaSeguroGeral('<? echo $operacao;?>', 2); return false;" />
</div>
<script type="text/javascript">
	hideMsgAguardo();
	controlaPesquisas('I_CASA');	
	
	$(document).ready(function(){
		highlightObjFocus($('#frmSeguroCasa'));
	});
</script>