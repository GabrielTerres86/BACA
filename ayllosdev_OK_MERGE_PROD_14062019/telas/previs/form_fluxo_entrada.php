<?
/*
 * FONTE        : form_fluxo_entrada.php
 * CRIAÇÃO      : Tiago Machado 
 * DATA CRIAÇÃO : 01/08/2012											ÚLTIMA ALTERAÇÃO: 23/03/2016
 * OBJETIVO     : form de entrada('E') da opcao fluxo na tela PREVIS.
 * --------------
 * ALTERAÇÕES   : 31/08/2012 - Ajuste projeto Fluxo Financeiro (Adriano).
 
			      23/03/2016 - Ajuste para mostrar valores de forma correta (Adriano).
 * --------------
 */
?>

 
	<fieldset id="fsetentrada" name="fsetentrada" style="padding:0px; margin:0px; padding-bottom:10px;">
		<legend> <? echo utf8ToHtml('Entradas'); ?> </legend>	
		
		<label for="cdbcova1">COMPE085</label>
		<label for="cdbcova2">BANCO DO BRASIL</label>
		<label for="cdbcova3">BANCOOB</label>
		<label for="cdbcova4">CONTA CECRED</label>

		<br />
		
		<label for="vlcheque">NR CHEQUES:</label>
		<label for="vlcheque1"></label>
		<input name="vlcheque1" id="vlcheque1" type="text" value="<?php echo formataMoeda(getByTagName($vlcheque,'vlcheque.1')); ?>" />
		<label for="vlcheque2"></label>
		<input name="vlcheque2" id="vlcheque2" type="text" value="<?php echo formataMoeda(getByTagName($vlcheque,'vlcheque.2')); ?>" />
		<label for="vlcheque3"></label>
		<input name="vlcheque3" id="vlcheque3" type="text" value="<?php echo formataMoeda(getByTagName($vlcheque,'vlcheque.3')); ?>" />
		<label for="vlcheque4"></label>
		<input name="vlcheque4" id="vlcheque4" type="text" value="<?php echo formataMoeda(getByTagName($vlcheque,'vlcheque.4')); ?>" />

		<br />
		
		<label for="vltotdoc">SR DOC:</label>
		<label for="vltotdoc1"></label>
		<input name="vltotdoc1" id="vltotdoc1" type="text" value="<?php echo formataMoeda(getByTagName($vltotdoc,'vltotdoc.1')); ?>" />
		<label for="vltotdoc2"></label>
		<input name="vltotdoc2" id="vltotdoc2" type="text" value="<?php echo formataMoeda(getByTagName($vltotdoc,'vltotdoc.2')); ?>" />
		<label for="vltotdoc3"></label>
		<input name="vltotdoc3" id="vltotdoc3" type="text" value="<?php echo formataMoeda(getByTagName($vltotdoc,'vltotdoc.3')); ?>" />
		<label for="vltotdoc4"></label>
		<input name="vltotdoc4" id="vltotdoc4" type="text" value="<?php echo formataMoeda(getByTagName($vltotdoc,'vltotdoc.4')); ?>" />

		<br />
		
		<label for="vltotted">SR TED:</label>
		<label for="vltotted1"></label>
		<input name="vltotted1" id="vltotted1" type="text" value="<?php echo formataMoeda(getByTagName($vltotted,'vltotted.1')); ?>" />
		<label for="vltotted2"></label>
		<input name="vltotted2" id="vltotted2" type="text" value="<?php echo formataMoeda(getByTagName($vltotted,'vltotted.2')); ?>" />
		<label for="vltotted3"></label>
		<input name="vltotted3" id="vltotted3" type="text" value="<?php echo formataMoeda(getByTagName($vltotted,'vltotted.3')); ?>" />
		<label for="vltotted4"></label>
		<input name="vltotted4" id="vltotted4" type="text" value="<?php echo formataMoeda(getByTagName($vltotted,'vltotted.4')); ?>" />

		<br />
		
		<label for="vltottit">SR T&Iacute;TULOS:</label>
		<label for="vltottit1"></label>
		<input name="vltottit1" id="vltottit1" type="text" value="<?php echo formataMoeda(getByTagName($vltottit,'vltottit.1')); ?>" />
		<label for="vltottit2"></label>
		<input name="vltottit2" id="vltottit2" type="text" value="<?php echo formataMoeda(getByTagName($vltottit,'vltottit.2')); ?>" />
		<label for="vltottit3"></label>
		<input name="vltottit3" id="vltottit3" type="text" value="<?php echo formataMoeda(getByTagName($vltottit,'vltottit.3')); ?>" />
		<label for="vltottit4"></label>
		<input name="vltottit4" id="vltottit4" type="text" value="<?php echo formataMoeda(getByTagName($vltottit,'vltottit.4')); ?>" />

		<br />
		
		<label for="vldevolu">DEV. CHEQUE REMETIDO:</label>
		<label for="vldevolu1"></label>
		<input name="vldevolu1" id="vldevolu1" type="text" value="<?php echo formataMoeda(getByTagName($vldevolu,'vldevolu.1')); ?>" />
		<label for="vldevolu2"></label>
		<input name="vldevolu2" id="vldevolu2" type="text" value="<?php echo formataMoeda(getByTagName($vldevolu,'vldevolu.2')); ?>" />
		<label for="vldevolu3"></label>
		<input name="vldevolu3" id="vldevolu3" type="text" value="<?php echo formataMoeda(getByTagName($vldevolu,'vldevolu.3')); ?>" />
		<label for="vldevolu4"></label>
		<input name="vldevolu4" id="vldevolu4" type="text" value="<?php echo formataMoeda(getByTagName($vldevolu,'vldevolu.4')); ?>" />

		<br />
		
		<label for="vlmvtitg">MVTO. CONTA ITG:</label>
		<label for="vlmvtitg1"></label>
		<input name="vlmvtitg1" id="vlmvtitg1" type="text" value="<?php echo formataMoeda(getByTagName($vlmvtitg,'vlmvtitg.1')); ?>" />
		<label for="vlmvtitg2"></label>
		<input name="vlmvtitg2" id="vlmvtitg2" type="text" value="<?php echo formataMoeda(getByTagName($vlmvtitg,'vlmvtitg.2')); ?>" />
		<label for="vlmvtitg3"></label>
		<input name="vlmvtitg3" id="vlmvtitg3" type="text" value="<?php echo formataMoeda(getByTagName($vlmvtitg,'vlmvtitg.3')); ?>" />
		<label for="vlmvtitg4"></label>
		<input name="vlmvtitg4" id="vlmvtitg4" type="text" value="<?php echo formataMoeda(getByTagName($vlmvtitg,'vlmvtitg.4')); ?>" />

		<br />
		
		<label for="vlttinss">INSS:</label>
		<label for="vlttinss1"></label>
		<input name="vlttinss1" id="vlttinss1" type="text" value="<?php echo formataMoeda(getByTagName($vlttinss,'vlttinss.1')); ?>" />
		<label for="vlttinss2"></label>
		<input name="vlttinss2" id="vlttinss2" type="text" value="<?php echo formataMoeda(getByTagName($vlttinss,'vlttinss.2')); ?>" />
		<label for="vlttinss3"></label>
		<input name="vlttinss3" id="vlttinss3" type="text" value="<?php echo formataMoeda(getByTagName($vlttinss,'vlttinss.3')); ?>" />
		<label for="vlttinss4"></label>
		<input name="vlttinss4" id="vlttinss4" type="text" value="<?php echo formataMoeda(getByTagName($vlttinss,'vlttinss.4')); ?>" />
		
		<br />
		
		<label for="vltrdeit">TRANSF/DEP INTER:</label>
		<label for="vltrdeit1"></label>
		<input name="vltrdeit1" id="vltrdeit1" type="text" value="<?php echo formataMoeda(getByTagName($vltrdeit,'vltrdeit.1')); ?>" />
		<label for="vltrdeit2"></label>
		<input name="vltrdeit2" id="vltrdeit2" type="text" value="<?php echo formataMoeda(getByTagName($vltrdeit,'vltrdeit.2')); ?>" />
		<label for="vltrdeit3"></label>
		<input name="vltrdeit3" id="vltrdeit3" type="text" value="<?php echo formataMoeda(getByTagName($vltrdeit,'vltrdeit.3')); ?>" />
		<label for="vltrdeit4"></label>
		<input name="vltrdeit4" id="vltrdeit4" type="text" value="<?php echo formataMoeda(getByTagName($vltrdeit,'vltrdeit.4')); ?>" />
		
		<br />
		
		<label for="vlsatait">SAQUE TAA INTERC:</label>
		<label for="vlsatait1"></label>
		<input name="vlsatait1" id="vlsatait1" type="text" value="<?php echo formataMoeda(getByTagName($vlsatait,'vlsatait.1')); ?>" />
		<label for="vlsatait2"></label>
		<input name="vlsatait2" id="vlsatait2" type="text" value="<?php echo formataMoeda(getByTagName($vlsatait,'vlsatait.2')); ?>" />
		<label for="vlsatait3"></label>
		<input name="vlsatait3" id="vlsatait3" type="text" value="<?php echo formataMoeda(getByTagName($vlsatait,'vlsatait.3')); ?>" />
		<label for="vlsatait4"></label>
		<input name="vlsatait4" id="vlsatait4" type="text" value="<?php echo formataMoeda(getByTagName($vlsatait,'vlsatait.4')); ?>" />

		<br />
		
		
		<fieldset id="fsetDiversosEntrada" name="fsetDiversosEntrada" style="border-right:none; border-left:none; width:100%; padding:0px; padding-bottom:10px; margin:0px;">
			<legend> <? echo utf8ToHtml('Diversos'); ?> </legend>	
						
			<label for="vlrepass">REPASSE RECURSOS:</label>
			<label for="vlrepass1"></label>
			<input name="vlrepass1" id="vlrepass1" type="text" value="<?php echo formataMoeda(getByTagName($vlrepass,'vlrepass.1')); ?>" />
			<label for="vlrepass2"></label>
			<input name="vlrepass2" id="vlrepass2" type="text" value="<?php echo formataMoeda(getByTagName($vlrepass,'vlrepass.2')); ?>" />
			<label for="vlrepass3"></label>
			<input name="vlrepass3" id="vlrepass3" type="text" value="<?php echo formataMoeda(getByTagName($vlrepass,'vlrepass.3')); ?>" />
			<label for="vlrepass4"></label>
			<input name="vlrepass4" id="vlrepass4" type="text" value="<?php echo formataMoeda(getByTagName($vlrepass,'vlrepass.4')); ?>" />

			<br />
			
			<label for="vlrfolha">FOLHA DE PAGTO:</label>
			<label for="vlrfolha1"></label>
			<input name="vlrfolha1" id="vlrfolha1" type="text" value="<?php echo formataMoeda(getByTagName($vlrfolha,'vlrfolha.1')); ?>" />
			<label for="vlrfolha2"></label>
			<input name="vlrfolha2" id="vlrfolha2" type="text" value="<?php echo formataMoeda(getByTagName($vlrfolha,'vlrfolha.2')); ?>" />
			<label for="vlrfolha3"></label>
			<input name="vlrfolha3" id="vlrfolha3" type="text" value="<?php echo formataMoeda(getByTagName($vlrfolha,'vlrfolha.3')); ?>" />
			<label for="vlrfolha4"></label>
			<input name="vlrfolha4" id="vlrfolha4" type="text" value="<?php echo formataMoeda(getByTagName($vlrfolha,'vlrfolha.4')); ?>" />
			
			<br />
			
			<label for="vlnumera">DEP&Oacute;SITO NUMER&Aacute;RIO:</label>
			<label for="vlnumera1"></label>
			<input name="vlnumera1" id="vlnumera1" type="text" value="<?php echo formataMoeda(getByTagName($vlnumera,'vlnumera.1')); ?>" />
			<label for="vlnumera2"></label>
			<input name="vlnumera2" id="vlnumera2" type="text" value="<?php echo formataMoeda(getByTagName($vlnumera,'vlnumera.2')); ?>" />
			<label for="vlnumera3"></label>
			<input name="vlnumera3" id="vlnumera3" type="text" value="<?php echo formataMoeda(getByTagName($vlnumera,'vlnumera.3')); ?>" />
			<label for="vlnumera4"></label>
			<input name="vlnumera4" id="vlnumera4" type="text" value="<?php echo formataMoeda(getByTagName($vlnumera,'vlnumera.4')); ?>" />
					
			<br />
			
			<label for="vloutros">OUTROS:</label>
			<label for="vloutros1"></label>
			<input name="vloutros1" id="vloutros1" type="text" value="<?php echo formataMoeda(getByTagName($vloutros,'vloutros.1')); ?>" />
			<label for="vloutros2"></label>
			<input name="vloutros2" id="vloutros2" type="text" value="<?php echo formataMoeda(getByTagName($vloutros,'vloutros.2')); ?>" />
			<label for="vloutros3"></label>
			<input name="vloutros3" id="vloutros3" type="text" value="<?php echo formataMoeda(getByTagName($vloutros,'vloutros.3')); ?>" />
			<label for="vloutros4"></label>
			<input name="vloutros4" id="vloutros4" type="text" value="<?php echo formataMoeda(getByTagName($vloutros,'vloutros.4')); ?>" />
				
			<br />

			<label for="vldivers">TOTAL DIVERSOS:</label>
			<label for="vldivers1"></label>
			<input name="vldivers1" id="vldivers1" type="text" value="<?php echo formataMoeda(getByTagName($vldivers,'vldivers.1')); ?>" />
			<label for="vldivers2"></label>
			<input name="vldivers2" id="vldivers2" type="text" value="<?php echo formataMoeda(getByTagName($vldivers,'vldivers.2')); ?>" />
			<label for="vldivers3"></label>
			<input name="vldivers3" id="vldivers3" type="text" value="<?php echo formataMoeda(getByTagName($vldivers,'vldivers.3')); ?>" />
			<label for="vldivers4"></label>
			<input name="vldivers4" id="vldivers4" type="text" value="<?php echo formataMoeda(getByTagName($vldivers,'vldivers.4')); ?>" />
					
				
		</fieldset>		
				
		<br style="clear:both" />
				
		<label for="vlttcrdb">TOTAL CR&Eacute;DITO:</label>
		<label for="vlttcrdb1"></label>
		<input name="vlttcrdb1" id="vlttcrdb1" type="text" value="<?php echo formataMoeda(getByTagName($vlttcrdb,'vlttcrdb.1')); ?>" />
		<label for="vlttcrdb2"></label>
		<input name="vlttcrdb2" id="vlttcrdb2" type="text" value="<?php echo formataMoeda(getByTagName($vlttcrdb,'vlttcrdb.2')); ?>" />
		<label for="vlttcrdb3"></label>
		<input name="vlttcrdb3" id="vlttcrdb3" type="text" value="<?php echo formataMoeda(getByTagName($vlttcrdb,'vlttcrdb.3')); ?>" />
		<label for="vlttcrdb4"></label>
		<input name="vlttcrdb4" id="vlttcrdb4" type="text" value="<?php echo formataMoeda(getByTagName($vlttcrdb,'vlttcrdb.4')); ?>" />
		
		
	</fieldset>		
