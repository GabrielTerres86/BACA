<? 
/*!
 * FONTE        : form_consultar.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 10/05/2019
 * OBJETIVO     : Formulário com dados do limite de crédito
 
 * ALTERAÇÕES   : 
 *
 */	
?>

<div id="divDadosLimiteCredito">
	
	<input id="nivrisco" name="nivrisco" type="hidden" />
	<input id="dsdtxfix" name="dsdtxfix" type="hidden" />

	<label for="vllimite"><? echo utf8ToHtml('Valor do Limite:') ?></label>	
	<input id="vllimite" name="vllimite" type="text" />	

	<label for="dtmvtolt"><? echo utf8ToHtml('Contrata&ccedil;&atilde;o:') ?></label>	
	<input id="dtmvtolt" name="dtmvtolt" type="text" />
	<br />
	
	<label for="cddlinha"><? echo utf8ToHtml('Linha:') ?></label>	
	<input id="cddlinha" name="cddlinha" type="text" />

	<label for="dtfimvig"><? echo utf8ToHtml('Data de T&eacute;rmino:') ?></label>	
	<input id="dtfimvig" name="dtfimvig" type="text" />
	<br />
	
	<label for="nrctrlim"><? echo utf8ToHtml('Contrato:') ?></label>	
	<input id="nrctrlim" name="nrctrlim" type="text" />	

	<label for="qtdiavig"><? echo utf8ToHtml('Vig&ecirc;ncia:') ?></label>	
	<input id="qtdiavig" name="qtdiavig" type="text" />
	<br />
	
	<label for="dstprenv"><? echo utf8ToHtml('Tipo Renova&ccedil;&atilde;o:') ?></label>	
	<input id="dstprenv" name="dstprenv" type="text" />	

	<label for="qtrenova"><? echo utf8ToHtml('Renova&ccedil;&otilde;es:') ?></label>
	<input id="qtrenova" name="qtrenova" type="text" />
	
	<label for="dtrenova"><? echo utf8ToHtml('Data Renova&ccedil;&atilde;o:') ?></label>
	<input id="dtrenova" name="dtrenova" type="text" />
	<br />
	
	<label for="dtcanlim"><? echo utf8ToHtml('Data Cancelamento:') ?></label>	
	<input id="dtcanlim" name="dtcanlim" type="text" />
	<br />
	
	<label for="dsencfi1"><? echo utf8ToHtml('Encargos Financeiros:') ?></label>	
	<input id="dsencfi1" name="dsencfi1" type="text" style="width: 322px;" />
	<br />
	
	<label for="dsencfi2"></label>	
	<input id="dsencfi2" name="dsencfi2" type="text" style="width: 322px;" />
	<br />
	
	<label for="dsencfi3"></label>	
	<input id="dsencfi3" name="dsencfi3" type="text" style="width: 322px;" />

	
	<label for="dssitlli"><? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?></label>	
	<input id="dssitlli" name="dssitlli" type="text" />	

	<label for="dtultmaj"><? echo utf8ToHtml('Ult. Majora&ccedil;&atilde;o:') ?></label>	
	<input id="dtultmaj" name="dtultmaj" type="text" />

	<br />

	<label for="nmoperad"><? echo utf8ToHtml('Operador(a) Proposta:') ?></label>	
	<input id="nmoperad" name="nmoperad" type="text" />
	<br />

	<label for="nmopelib"><? echo utf8ToHtml('Operador(a) Libera&ccedil;&atilde;o:') ?></label>	
	<input id="nmopelib" name="nmopelib" type="text" />
	<br />

	<label for="flgenvio"><? echo utf8ToHtml('Comit&ecirc;:') ?></label>	
	<input id="flgenvio" name="flgenvio" type="text" />

	<br />	

</div>

<div id="divBotoes" align="center">

	<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="acessaTela('@');return false;">
	<?php if ($cddopcao == 'R') { // Se for renovacao ?>

		<input type="image" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="showConfirmacaoRenovar(); return false;"> 

	<?php } else { // Se for consulta ?> 

		<input type="image" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="abrirGaropc(); return false;"> 
		
	<?php } ?>

</div>

<script type="text/javascript">
    
    setarDadosLimiteCredito();
	formataDadosLimiteCredito();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	
</script>