<? 
/*!
 * FONTE        : tabela_dados.php
 * CRIAÇÃO      : Gabriel Santos - DB1 Informatica
 * DATA CRIAÇÃO : 30/03/2010 
 * OBJETIVO     : Tabela que apresenta os dados do Sistema Financeiro
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [05/05/2010] Rodolpho Telmo (DB1) : Adaptação da tela ao "tableSorter"
 * 002: [05/08/2015] Gabriel (RKAM)       : Reformulacao cadastral. 
 */	  
?>

<div id="divTabelaDadosFin" class="divRegistros">
	<table>
		<thead>
			<tr><th>Banco</th>
				<th>Ag&ecirc;ncia</th>
				<th>Conta</th>
				<th>DV</th>
				<th>Abertura</th>
				<th>Inst. Financ.</th></tr>			
		</thead>
		<tbody>
			<? foreach( $registros as $sisFini ) {?>
				<tr><td><span><? echo getByTagName($sisFini->tags,'cddbanco') ?></span>
					<? echo getByTagName($sisFini->tags,'cddbanco') ?>
					<input type="hidden" id="dtmvtosf" name="dtmvtosf" value="<? echo getByTagName($sisFini->tags,'dtmvtosf') ?>" />
					<input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($sisFini->tags,'dtmvtolt') ?>" />
					<input type="hidden" id="hrtransa" name="hrtransa" value="<? echo getByTagName($sisFini->tags,'hrtransa') ?>" />
					<input type="hidden" id="nrseqdig" name="nrseqdig" value="<? echo getByTagName($sisFini->tags,'nrseqdig') ?>" />					
					<input type="hidden" id="flgenvio" name="flgenvio" value="<? echo getByTagName($sisFini->tags,'flgenvio') ?>" />
					<input type="hidden" id="dtdenvio" name="dtdenvio" value="<? echo getByTagName($sisFini->tags,'dtdenvio') ?>" />
					<input type="hidden" id="insitcta" name="insitcta" value="<? echo getByTagName($sisFini->tags,'insitcta') ?>" />
					<input type="hidden" id="dtdemiss" name="dtdemiss" value="<? echo getByTagName($sisFini->tags,'dtdemiss') ?>" />
					<input type="hidden" id="cdmotdem" name="cdmotdem" value="<? echo getByTagName($sisFini->tags,'cdmotdem') ?>" />				
					<input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($sisFini->tags,'nrdrowid') ?>" /></td>
					<td><? echo getByTagName($sisFini->tags,'cdageban') ?></td>
					<td><? echo getByTagName($sisFini->tags,'nrdctasf') ?></td>
					<td><? echo getByTagName($sisFini->tags,'dgdconta') ?></td>
					<td><span><? echo dataParaTimestamp(getByTagName($sisFini->tags,'dtabtcct')) ?></span>
						<? echo getByTagName($sisFini->tags,'dtabtcct') ?></td>
					<td><? echo stringTabela(getByTagName($sisFini->tags,'nminsfin'),17,'maiuscula') ?></td></tr>				
			<? } ?>			
		</tbody>
	</table>
</div> 
	
<div id="divBotoes">
		
	<? if ($flgcadas == 'M' ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
	<? } else { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);" />
	<? } ?>
	<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacao('FD');" />
	<input type="image" id="btExcluir" src="<? echo $UrlImagens; ?>botoes/excluir.gif" onClick="controlaOperacao('VED');" />
	<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="controlaOperacao('FI');" />	
	<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="proximaRotina();" />	
</div>