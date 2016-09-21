<? 
/*!
 * FONTE        : tabela_seguro.php
 * CRIAÇÃO      : Marcelo Leandro Pereira
 * DATA CRIAÇÃO : 19/09/2011
 * OBJETIVO     : Tabela que apresenta os seguros
 * --------------
 * ALTERAÇÕES   : Michel M Candido
 * DATA CRIAÇÃO : 19/09/2011
 */
?>
<div id="divSeguro" class="divRegistros">
	<table>
		<thead>
			<tr>
				<th><? echo utf8ToHtml('Início');?></th>
				<th>Proposta</th>
				<th>Dia</th>
				<th>Tipo</th>
				<th><? echo utf8ToHtml('Prestação');?></th>
				<th><? echo utf8ToHtml('Início Vig');?></th>
				<th><? echo utf8ToHtml('Situação');?></th>
			</tr>
		</thead>		
		<tbody>
			<?
				foreach( $seguros as $seguro ) {
				?>
				<tr>
					<td>
						<? echo getByTagName($seguro->tags,'dtiniseg'); ?>
						<input type="hidden" id="idproposta" name="idproposta" value="<? echo getByTagName($seguro->tags,'nrctrseg'); ?>" />
						<input type="hidden" id="dsseguro" name="dsseguro" value="<? echo getByTagName($seguro->tags,'dsseguro'); ?>" />
						<input type="hidden" id="tpseguro" name="tpseguro" value="<? echo getByTagName($seguro->tags,'tpseguro'); ?>" />
						<input type="hidden" id="dsstatus" name="dsstatus" value="<? echo getByTagName($seguro->tags,'dsStatus'); ?>" />
						<input type="hidden" id="nrctrseg" name="nrctrseg" value="<? echo getByTagName($seguro->tags,'nrctrseg'); ?>" />
						<input type="hidden" id="nmdsegur" name="nmdsegur" value="<? echo getByTagName($seguro->tags,'nmdsegur'); ?>" />
						<input type="hidden" id="vlpreseg" name="vlpreseg" value="<? echo getByTagName($seguro->tags,'vlpreseg'); ?>" />
						<input type="hidden" id="tpplaseg" name="tpplaseg" value="<? echo getByTagName($seguro->tags,'tpplaseg'); ?>" />
						<input type="hidden" id="dtinivig" name="dtinivig" value="<? echo getByTagName($seguro->tags,'dtinivig'); ?>" />
						<input type="hidden" id="qtpreseg" name="qtpreseg" value="<? echo getByTagName($seguro->tags,'qtprepag'); ?>" />
						<input type="hidden" id="dtcancel" name="dtcancel" value="<? echo getByTagName($seguro->tags,'dtcancel'); ?>" />
						<input type="hidden" id="vlprepag" name="vlprepag" value="<? echo getByTagName($seguro->tags,'vlprepag'); ?>" />
						<input type="hidden" id="dtdebito" name="dtdebito" value="<? echo getByTagName($seguro->tags,'dtdebito'); ?>" />
						<input type="hidden" id="dtiniseg" name="dtiniseg" value="<? echo getByTagName($seguro->tags,'dtiniseg'); ?>" />
						<input type="hidden" id="cdsegura" name="cdsegura" value="<? echo getByTagName($seguro->tags,'cdsegura'); ?>" />
						<input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($seguro->tags,'dtmvtolt'); ?>" />
						<input type="hidden" id="cdsexosg" name="cdsexosg" value="<? echo getByTagName($seguro->tags,'cdsexosg'); ?>" />
						<input type="hidden" id="qtparcel" name="qtparcel" value="<? echo getByTagName($seguro->tags,'qtparcel'); ?>" />
						<input type="hidden" id="cdsitseg" name="cdsitseg" value="<? echo getByTagName($seguro->tags,'cdsitseg'); ?>" />
						
						
						<input type="hidden" id="nmbenefi_1" name="nmbenefi_1" value="<? echo $seguro->tags[28]->tags[0]->cdata; ?>" />
						<input type="hidden" id="nmbenefi_2" name="nmbenefi_2" value="<? echo $seguro->tags[28]->tags[1]->cdata; ?>" />
						<input type="hidden" id="nmbenefi_3" name="nmbenefi_3" value="<? echo $seguro->tags[28]->tags[2]->cdata; ?>" />
						<input type="hidden" id="nmbenefi_4" name="nmbenefi_4" value="<? echo $seguro->tags[28]->tags[3]->cdata; ?>" />
						<input type="hidden" id="nmbenefi_5" name="nmbenefi_5" value="<? echo $seguro->tags[28]->tags[4]->cdata; ?>" />
						
						<input type="hidden" id="dsgraupr_1" name="dsgraupr_1" value="<? echo $seguro->tags[29]->tags[0]->cdata; ?>" />
						<input type="hidden" id="dsgraupr_2" name="dsgraupr_2" value="<? echo $seguro->tags[29]->tags[1]->cdata; ?>" />
						<input type="hidden" id="dsgraupr_3" name="dsgraupr_3" value="<? echo $seguro->tags[29]->tags[2]->cdata; ?>" />
						<input type="hidden" id="dsgraupr_4" name="dsgraupr_4" value="<? echo $seguro->tags[29]->tags[3]->cdata; ?>" />
						<input type="hidden" id="dsgraupr_5" name="dsgraupr_5" value="<? echo $seguro->tags[29]->tags[4]->cdata; ?>" />
						
						
						<? $txpartic1 = $seguro->tags[30]->tags[0]->cdata; ?>
						<? $txpartic2 = $seguro->tags[30]->tags[1]->cdata; ?>
						<? $txpartic3 = $seguro->tags[30]->tags[2]->cdata; ?>
						<? $txpartic4 = $seguro->tags[30]->tags[3]->cdata; ?>
						<? $txpartic5 = $seguro->tags[30]->tags[4]->cdata; ?>
						<input type="hidden" id="txpartic_1" name="txpartic_1" value="<? echo $txpartic1; ?>" />						
						<input type="hidden" id="txpartic_2" name="txpartic_2" value="<? echo $txpartic2; ?>" />
						<input type="hidden" id="txpartic_3" name="txpartic_3" value="<? echo $txpartic3; ?>" />
						<input type="hidden" id="txpartic_4" name="txpartic_4" value="<? echo $txpartic4; ?>" />
						<input type="hidden" id="txpartic_5" name="txpartic_5" value="<? echo $txpartic5; ?>" />
						
					</td>	
					<td><? echo formataNumericos("zz.zzz.zz9",getByTagName($seguro->tags,'nrctrseg'),".")?></td>
					<td><? echo getByTagName($seguro->tags,'dtdebito'); ?></td>
					<td><? echo getByTagName($seguro->tags,'dsseguro'); ?></td>
					<td><? echo getByTagName($seguro->tags,'vlpreseg'); ?></td>
					<td><? echo getByTagName($seguro->tags,'dtinivig'); ?></td>
					<td><? echo getByTagName($seguro->tags,'dsstatus'); ?></td>
				</tr>
			<? } ?>
		</tbody>
	</table>
</div>

<div id="divBotoes">
	<input type="image" id="btIncluir"   src="<? echo $UrlImagens; ?>botoes/incluir.gif"   <?php if (!in_array("I",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="controlaOperacao(\'I\');"'; } ?> />
	<input type="image" id="btAlterar"   src="<? echo $UrlImagens; ?>botoes/alterar.gif"   <?php if (!in_array("A",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="controlaOperacao(\'ALTERAR\');"'; } ?>  />
	<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" <?php if (!in_array("C",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="controlaOperacao(\'CONSULTAR\');"'; } ?>   />
	<input type="image" id="btCancelar"   src="<? echo $UrlImagens; ?>botoes/cancelar.gif" <?php if (!in_array("X",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="controlaOperacao(\'C\');"'; } ?>   />
	<input type="image" id="btImprimir"  src="<? echo $UrlImagens; ?>botoes/imprimir.gif"  <?php if (!in_array("M",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="controlaOperacao(\'IMP\');"'; } ?>  />
</div>