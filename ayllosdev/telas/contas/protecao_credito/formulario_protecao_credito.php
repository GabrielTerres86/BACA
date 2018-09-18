<? 
/*!
 * FONTE        : formulario_protecao_credito.php
 * CRIAÇÃO      : Jonata (Rkam)
 * DATA CRIAÇÃO : 11/08/2014 
 * OBJETIVO     : Rotina para validar/alterar os dados do Protecao ao Credito da tela de CONTAS
 * ALTERACOES	: 12/01/2016 - Inclusao do parametro de assinatura conjunta, Prj. 131 (Jean Michel)
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [21/03/2016] Incluido dados consulta Boa Vista - PRJ207 Esteira -  (Odirlei/AMcom)
 */
?>

<form name="frmImpressao" id="frmImpressao" action="<?php echo $UrlSite; ?>telas/contas/protecao_credito/carrega_impressao.php" method="post">
	<input type="hidden" name="nrconbir" id="nrconbir" value="">
	<input type="hidden" name="nrseqdet" id="nrseqdet" value="">
	<input type="hidden" name="cdbircon" id="cdbircon" value="">
	<input type="hidden" name="cdmodbir" id="cdmodbir" value="">
	<input type="hidden" name="nrdconta" id="nrdconta" value="">
	<input type="hidden" name="inpessoa" id="inpessoa" value="">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>

<form name="frmDadosProtecao" id="frmDadosProtecao" class="formulario">

	<input type="hidden" id="cdagepac" value="<? echo getByTagName($registro,'cdagepac')  ?>">
	<input type="hidden" id="cdsitdct" value="<? echo getByTagName($registro,'cdsitdct')  ?>">
	<input type="hidden" id="cdtipcta" value="<? echo getByTagName($registro,'cdtipcta')  ?>">
	<input type="hidden" id="cdbcochq" value="<? echo getByTagName($registro,'cdbcochq')  ?>">
	<input type="hidden" id="nrdctitg" value="<? echo getByTagName($registro,'nrdctitg')  ?>">
	<input type="hidden" id="cdagedbb" value="<? echo getByTagName($registro,'cdagedbb')  ?>">
	<input type="hidden" id="cdbcoitg" value="<? echo getByTagName($registro,'cdbcoitg')  ?>">
	<input type="hidden" id="cdsecext" value="<? echo getByTagName($registro,'cdsecext')  ?>">
	<input type="hidden" id="dtcnsscr" value="<? echo getByTagName($registro,'dtcnsscr')  ?>">
	<input type="hidden" id="dtabtcoo" value="<? echo getByTagName($registro,'dtabtcoo')  ?>">
	<input type="hidden" id="dtelimin" value="<? echo getByTagName($registro,'dtelimin')  ?>">
	<input type="hidden" id="dtabtcct" value="<? echo getByTagName($registro,'dtabtcct')  ?>">
	<input type="hidden" id="dtdemiss" value="<? echo getByTagName($registro,'dtdemiss')  ?>">
	<input type="hidden" id="flgcrdpa" value="<? echo getByTagName($registro,'flgcrdpa')  ?>">
	<input type="hidden" id="flgiddep" value="<? echo getByTagName($registro,'flgiddep')  ?>">
	<input type="hidden" id="tpavsdeb" value="<? echo getByTagName($registro,'tpavsdeb')  ?>">
	<input type="hidden" id="tpextcta" value="<? echo getByTagName($registro,'tpextcta')  ?>">
	<input type="hidden" id="inlbacen" value="<? echo getByTagName($registro,'inlbacen')  ?>">
	<input type="hidden" id="flgrestr" value="<? echo getByTagName($registro,'flgrestr')  ?>">
    <input type="hidden" id="dtdscore" value="<? echo getByTagName($registro,'dtdscore')  ?>">
    <input type="hidden" id="dsdscore" value="<? echo getByTagName($registro,'dsdscore')  ?>">
	<input type="hidden" id="idastcjt" value="<? echo getByTagName($registro,'idastcjt')  ?>">
	<input type="hidden" id="cdcatego" value="<? echo getByTagName($registro,'cdcatego')  ?>">
	<input type="hidden" id="nrconbir" value="<? echo $nrconbir;  ?>">
	<input type="hidden" id="nrseqdet" value="<? echo $nrseqdet;  ?>">
	<input type="hidden" id="cdbircon" value="<? echo $cdbircon;  ?>">
	<input type="hidden" id="cdmodbir" value="<? echo $cdmodbir;  ?>">

	<fieldset>
		
		<legend>Principal</legend>
				
		<label for="dtcnsspc"> <? echo ($dsbircon == "Serasa") ? "Consulta Serasa(outras inst.):" : "Consulta SPC:" ?> </label>
		<input name="dtcnsspc" id="dtcnsspc" type="text" value="<? echo getByTagName($registro,'dtcnsspc') ?>" class="data" />
		
		<label for="dtdsdspc">SPC p/COOP:</label>
		<input name="dtdsdspc" id="dtdsdspc" type="text" value="<? echo getByTagName($registro,'dtdsdspc') ?>" class="data" />
		
		<br />
		
		<label for="inadimpl">Esta no SPC(coop):</label>
		<input name="inadimpl" id="inadimpl_1" type="radio" class="radio" value="1" <? if (getByTagName($registro,'inadimpl') == '1') { echo ' checked'; } ?> />
		<label for="inadimpl_1" class="radio">Sim</label>		
		<input name="inadimpl" id="inadimpl_2" type="radio" class="radio" value="0" <? if (getByTagName($registro,'inadimpl') == '0') { echo ' checked'; } ?> />
		<label for="inadimpl_2" class="radio"><? echo utf8ToHtml('Não') ?></label>	
		
		
		<label for="dsinaout"> <? echo ($dsbircon == "Serasa") ? "Esta no Serasa(outras inst.):" : "Esta no SPC(outras inst.):" ?> </label>
		<input name="dsinaout" id="dsinaout_1" type="radio" class="radio" value="0" <? if ($flsituac == 'S') { echo ' checked'; } ?> />
		<label for="dsinaout_1" class="radio">Sim</label>		
		<input name="dsinaout" id="dsinaout_2" type="radio" class="radio" value="1" <? if ($flsituac == 'N') { echo ' checked'; } ?> />
		<label for="dsinaout_2" class="radio"><? echo utf8ToHtml('Não') ?></label>	
		<input name="dsinaout" id="dsinaout_3" type="radio" class="radio" value="2" <? if ($flsituac == '') { echo ' checked'; } ?> />
		<label for="dsinaout_3" class="radio"><? echo utf8ToHtml('Sem consulta') ?></label>	
		
		<br />

		<label for="dtdscore">Consulta Boa Vista: </label>
		<input name="dtdscore" id="dtdscore" type="text" value="<? echo getByTagName($registro,'dtdscore') ?>" class="data" />
		<label for="dsdscore"> Score:  </label>
		<input name="dsdscore" id="dsdscore" type="text" value="<? echo getByTagName($registro,'dsdscore') ?> " />
		

	</fieldset>
</form>

<div id="divBotoes">		
	<? if ( in_array($operacao,array('AC','FA','')) ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina)" />
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('CA')" />
		
		<? if  ($nrconbir != 0 && $nrseqdet != 0) { ?>	
			<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/detalhar.gif" onClick="controlaOperacao('DA')" />
		<? } ?>
		
	<? } else if ( $operacao == 'CA' ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AC')" />		
		<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV')" />
	<? } else if ( $operacao == 'SC' ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina)" />
	<? }?>
</div>