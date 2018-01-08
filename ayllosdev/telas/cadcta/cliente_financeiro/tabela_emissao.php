<? 
/*!
 * FONTE        : tabela_emissao.php
 * CRIAÇÃO      : Gabriel Santos - DB1 Informatica
 * DATA CRIAÇÃO : 30/03/2010 
 * OBJETIVO     : Tabela que apresenda os dados do Sistema Financeiro
 *
 * ALTERACOES   : [05/08/2015] Gabriel (RKAM)       : Reformulacao cadastral.
 */	
?>

<div id="divTabelaEmissaoFin" class="divRegistros">
	<table>
		<thead>
			<tr><th>Banco Dest.</th>
				<th>Ag&ecirc;ncia Dest.</th>
				<th>Data de Envio</th></tr>			
		</thead>
		<tbody>
			<? foreach( $registros as $sisFini ) {?>
				<tr><td><span><? echo getByTagName($sisFini->tags,'cddbanco') ?></span>
						<? echo getByTagName($sisFini->tags,'cddbanco') ?>
						<input type="hidden" id="dtmvtosf" name="dtmvtosf" value="<? echo getByTagName($sisFini->tags,'dtmvtosf') ?>" />
						<input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($sisFini->tags,'dtmvtolt') ?>" />
						<input type="hidden" id="nrseqdig" name="nrseqdig" value="<? echo getByTagName($sisFini->tags,'nrseqdig') ?>" />						
						<input type="hidden" id="hrtransa" name="hrtransa" value="<? echo getByTagName($sisFini->tags,'hrtransa') ?>" />						
						<input type="hidden" id="flgenvio" name="flgenvio" value="<? echo getByTagName($sisFini->tags,'flgenvio') ?>" />
						<input type="hidden" id="dtdenvio" name="dtdenvio" value="<? echo getByTagName($sisFini->tags,'dtdenvio') ?>" />
						<input type="hidden" id="insitcta" name="insitcta" value="<? echo getByTagName($sisFini->tags,'insitcta') ?>" />
						<input type="hidden" id="dtdemiss" name="dtdemiss" value="<? echo getByTagName($sisFini->tags,'dtdemiss') ?>" />
						<input type="hidden" id="cdmotdem" name="cdmotdem" value="<? echo getByTagName($sisFini->tags,'cdmotdem') ?>" />						
						<input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($sisFini->tags,'nrdrowid') ?>" /></td>
					<td><? echo getByTagName($sisFini->tags,'cdageban') ?></td>
					<td><? echo getByTagName($sisFini->tags,'dtdenvio') ?></td></tr>				
			<? } ?>			
		</tbody>
	</table>
</div>
	
<div id="divBotoes">
	<? if ($flgcadas == 'M') { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
	<? } else { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);" />
	<? } ?>	
	<input type="image" id="btExcluir"  src="<? echo $UrlImagens; ?>botoes/excluir.gif"  onClick="controlaOperacao('VEE');" />			
	<input type="image" id="btIncluir"  src="<? echo $UrlImagens; ?>botoes/incluir.gif"  onClick="controlaOperacao('FE');" />
	<input type="image" id="btImprimir" src="<? echo $UrlImagens; ?>botoes/imprimir.gif" onClick="imprimeFichaCadastralCF();" />	
	<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="proximaRotina();" />	
</div>