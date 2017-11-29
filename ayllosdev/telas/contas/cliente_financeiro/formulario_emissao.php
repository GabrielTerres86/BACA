<? 
/*!
 * FONTE        : formulario_emissao.php
 * CRIAÇÃO      : Gabriel C. Santos (DB1)
 * DATA CRIAÇÃO : 04/03/2010 
 * OBJETIVO     : Forumlário de dados de Formulario emissao
 *
 * ALTERACOES   : 24/09/2015 - Reformulacao cadastral (Gabriel).
 *				  29/11/2017 - Correcao no carregamento do campo cod.banco. SD 803263 Carlos Rafael Tanholi.
 */	
?>
<form name="formEmissaoSistFinanc" id="formEmissaoSistFinanc" class="formulario">

	<input type="hidden" id="dtabtcct" name="dtabtcct" value="" />
	<input type="hidden" id="dgdconta" name="dgdconta" value="" />
	<input type="hidden" id="dtmvtolt" name="dtmvtolt" value="" />
	<input type="hidden" id="dtmvtosf" name="dtmvtosf" value="" />
	<input type="hidden" id="hrtransa" name="hrtransa" value="" />
	<input type="hidden" id="nrdctasf" name="nrdctasf" value="" />
	<input type="hidden" id="nminsfin" name="nminsfin" value="" />
	<input type="hidden" id="nrseqdig" name="nrseqdig" value="" />
	<input type="hidden" id="flgenvio" name="flgenvio" value="" />
	<input type="hidden" id="dtdenvio" name="dtdenvio" value="" />
	<input type="hidden" id="insitcta" name="insitcta" value="" />
	<input type="hidden" id="dtdemiss" name="dtdemiss" value="" />
	<input type="hidden" id="cdmotdem" name="cdmotdem" value="" />

	<label for="cddbanco" class="rotulo rotulo-80">C&oacute;d. Banco:</label> 
	<input name="cddbanco" id="cddbanco" type="text" class="codigo pesquisa" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<input name="nmdbanco" id="nmdbanco" type="text" class="descricao" />
	<br />
	
	<label for="cdageban" class="rotulo rotulo-80">C&oacute;d. Ag&ecirc;ncia:</label>
	<input name="cdageban" id="cdageban" type="text" class="codigo pesquisa" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<input name="nmageban" id="nmageban" type="text" class="descricao" />
	<br style="clear:both" />
	
</form>

<div id="divBotoes">
	<input type="image" id="btVoltar"   src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('CO');return false;" />
	<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('VE');return false;" />
</div>

<script type="text/javascript">
	$('#cddbanco','#formEmissaoSistFinanc').focus();
</script>