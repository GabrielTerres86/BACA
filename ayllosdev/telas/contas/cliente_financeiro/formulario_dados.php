<? 
/*!
 * FONTE        : formulario_conjuge.php
 * CRIAÇÃO      : Gabriel C. Santos (DB1)
 * DATA CRIAÇÃO : 04/03/2010 
 * OBJETIVO     : Forumlário de dados de Cônjuge
 * --------------
 * ALTERAÇÕES   : 29/11/2017  - Correcao no carregamento do campo cod.banco. SD 803263 Carlos Rafael Tanholi.
 */
?>

<form name="formDadosSistFinanc" id="formDadosSistFinanc" class="formulario">

	<input type="hidden" id="dtmvtosf" name="dtmvtosf" value="<? echo getByTagName($registros[0]->tags,'dtmvtosf') ?>" />
	<input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($registros[0]->tags,'dtmvtolt') ?>" />
	<input type="hidden" id="hrtransa" name="hrtransa" value="<? echo getByTagName($registros[0]->tags,'hrtransa') ?>" />
	<input type="hidden" id="nrseqdig" name="nrseqdig" value="<? echo getByTagName($registros[0]->tags,'nrseqdig') ?>" />
	<input type="hidden" id="flgenvio" name="flgenvio" value="<? echo getByTagName($registros[0]->tags,'flgenvio') ?>" />
	<input type="hidden" id="dtdenvio" name="dtdenvio" value="<? echo getByTagName($registros[0]->tags,'dtdenvio') ?>" />
	<input type="hidden" id="insitcta" name="insitcta" value="<? echo getByTagName($registros[0]->tags,'insitcta') ?>" />
	<input type="hidden" id="dtdemiss" name="dtdemiss" value="<? echo getByTagName($registros[0]->tags,'dtdemiss') ?>" />
	<input type="hidden" id="cdmotdem" name="cdmotdem" value="<? echo getByTagName($registros[0]->tags,'cdmotdem') ?>" />

	<label for="dtabtcct" class="rotulo rotulo-80">Dt. Abertura:</label>
	<input name="dtabtcct" id="dtabtcct" type="text" class="data" value="<? echo getByTagName($registros[0]->tags,'dtabtcct') ?>" />
	<br />
	
	<label for="cdbccxlt" class="rotulo rotulo-80">C&oacute;d. Banco:</label>
	<input name="cdbccxlt" id="cdbccxlt" type="text" class="codigo pesquisa" value="<? echo getByTagName($registros[0]->tags,'cddbanco') ?>"  />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<input name="nmdbanco" id="nmdbanco" type="text" class="descricao" value="<? echo getByTagName($registros[0]->tags,'nmdbanco') ?>" />
	<br />
	
	<label for="cdageban" class="rotulo rotulo-80">C&oacute;d. Ag&ecirc;ncia:</label>
	<input name="cdageban" id="cdageban" type="text" class="codigo pesquisa" value="<? echo getByTagName($registros[0]->tags,'cdageban') ?>"  />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<input name="nmageban" id="nmageban" type="text" class="descricao" value="<? echo getByTagName($registros[0]->tags,'nmageban') ?>" />
	<br />
	
	<label for="nrdctasf" class="rotulo rotulo-80">Nr. Conta C/C:</label>
	<input name="nrdctasf" id="nrdctasf" type="text" class="inteiro" maxlength="10" value="<? echo getByTagName($registros[0]->tags,'nrdctasf') ?>" />
	
	<label for="dgdconta" class="rotulo-linha">DV:</label>
	<input name="dgdconta" id="dgdconta" type="text" class="alphanum" maxlength="1" value="<? echo getByTagName($registros[0]->tags,'dgdconta') ?>" />
	<br />
	
	<label for="nminsfin" class="rotulo rotulo-120">Institui&ccedil;&atilde;o Financeira:</label>
	<input name="nminsfin" id="nminsfin" type="text" class="alphanum" value="<? echo getByTagName($registros[0]->tags,'nminsfin') ?>" />
	<br /> 
	
	<br clear="both" />
</form>

<div id="divBotoes">
	<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="controlaOperacao('CO');return false;" />
	<? if ( $operacao == 'FD' ) { ?> <input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('VA');return false;" />	<? } ?>
	<? if ( $operacao == 'FI' ) { ?> <input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('VD');return false;" />	<? } ?>		
</div>