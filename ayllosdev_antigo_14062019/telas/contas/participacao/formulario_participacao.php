<?
/*!
 * FONTE        : formulario_participacao.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : 31/08/2011
 * OBJETIVO     : Forumlário de dados de participacao empresas para alteração
 * --------------
 * ALTERAÇÕES   : Adicionado maxlength no campo nmprimtl para 40 para não estourar
				  o campo no banco. Isso para resolver o problema referente ao chamado
				  470636. (Kelvin)
 * --------------
 */	
?>
	
<div id="divEmpresas">
	
	<form name="frmParticipacaoEmpresas" id="frmParticipacaoEmpresas" class="formulario">		
		<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($registros[0]->tags,'nrdconta') ?>" />
		
		<label for="nrdctato" class="rotulo rotulo-90">Conta/dv:</label>
		<input name="nrdctato" id="nrdctato" type="text" value="<? echo getByTagName($registros[0]->tags,'cddconta')?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		
		<label for="nrcpfcgc" class="rotulo-linha" style="width: 217px;">C.N.P.J:</label>
		<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="<? echo getByTagName($registros[0]->tags,'cdcpfcgc') ?>" />
		<br />
		
		<label for="nmprimtl" class="rotulo rotulo-90">Raz&atilde;o Social:</label>
		<input name="nmprimtl" id="nmprimtl" type="text" class="alphanum" maxlength="40" value="<? echo getByTagName($registros[0]->tags,'nmprimtl') ?>" />
		<br />
		
		<label for="nmfatasi" class="rotulo rotulo-90">Nome Fantasia:</label>
		<input name="nmfatasi" id="nmfatasi" type="text" class="alphanum" maxlength="40" value="<? echo getByTagName($registros[0]->tags,'nmfansia') ?>" />
		<br />
		
		<label for="cdnatjur" class="rotulo rotulo-90">Nat. Jur&iacute;dica:</label>
		<input name="cdnatjur" id="cdnatjur" type="text" class="codigo pesquisa" value="<? echo getByTagName($registros[0]->tags,'natjurid') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		<input name="dsnatjur" id="dsnatjur" type="text" class="descricao" value="<? echo getByTagName($registros[0]->tags,'dsnatjur') ?>" />
		<br />		

		<label for="qtfilial" class="rotulo rotulo-90">Qt. Filiais:</label>
		<input name="qtfilial" id="qtfilial" type="text" class="codigo"  maxlength="3" value="<? echo getByTagName($registros[0]->tags,'qtfilial') ?>" />
		
		<label for="qtfuncio">Qt. Funcion&aacute;rios:</label>
		<input name="qtfuncio" id="qtfuncio" type="text" class="codigo" maxlength="6" value="<? echo getByTagName($registros[0]->tags,'qtfuncio') ?>" />
		
		<label for="dtiniatv" class="rotulo-80">In&iacute;cio Ativ.:</label>
		<input name="dtiniatv" id="dtiniatv" type="text" class="data" value="<? echo getByTagName($registros[0]->tags,'dtiniatv') ?>" />
		<br />
		
		<label for="cdseteco" class="rotulo rotulo-90">Setor Econ.:</label>																	
		<input name="cdseteco" id="cdseteco" type="text" class="codigo pesquisa" value="<? echo getByTagName($registros[0]->tags,'cdseteco') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		<input name="nmseteco" id="nmseteco" type="text" class="descricao" value="<? echo getByTagName($registros[0]->tags,'nmseteco') ?>" />
		<br />		
		
		<label for="cdrmativ" class="rotulo rotulo-90">Ramo Ativ.:</label>
		<input name="cdrmativ" id="cdrmativ" type="text" class="codigo pesquisa" value="<? echo getByTagName($registros[0]->tags,'cdrmativ') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		<input name="dsrmativ" id="dsrmativ" type="text" class="descricao" value="<? echo getByTagName($registros[0]->tags,'dsrmativ') ?>" />
		<br />			

		<label for="dsendweb" class="rotulo" style="width:140px;">Endere&ccedil;o Internet (Site):</label>
		<input name="dsendweb" id="dsendweb" type="text" class="url" maxlength="40" value="<? echo getByTagName($registros[0]->tags,'dsendweb') ?>" />
		<a class="link"><img src="<? echo $UrlImagens; ?>icones/link.png" alt="Acessar Site" /></a>
		<br/>
		
		<label for="persocio" class="rotulo rotulo-90"><? echo utf8ToHtml('% Societário:') ?></label>
		<input name="persocio" id="persocio" type="text" class="moeda" value="<? echo getByTagName($registros[0]->tags,'persocio') ?>" />
		
		<label for="dtadmsoc" class="rotulo-90">Data Admiss&atilde;o:</label>
		<input name="dtadmsoc" id="dtadmsoc" type="text" class="data" value="<? echo getByTagName($registros[0]->tags,'dtadmiss'); ?>" />
		
		<label for="vledvmto" class="rotulo-90">Endividamento:</label>
		<input name="vledvmto" id="vledvmto" type="text" class="moeda" maxlength="18" value="<? echo getByTagName($registros[0]->tags,'vledvmto') ?>" />
		<br clear="both" />
	</form>

	<div id="divBotoes">
		<? if ( $operacao == 'CF' ) { ?>		
			<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('CT');return false;" />	
		<? } else if ( $operacao == 'A' ) { ?>		
			<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('AT');return false;" />		
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV');return false;" />		
		<? } else if ( $operacao == 'I' || $operacao == 'IB' ) { ?>	
			<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('IT');return false;" />		
			<input type="image" id="btLimpar" src="<? echo $UrlImagens; ?>botoes/limpar.gif"   onClick="estadoInicial();return false;" />
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('IV');return false;" />		
		<? } ?>
	</div>	
</div>