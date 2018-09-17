<?
/*!
 * FONTE        : form_cadspc.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 06/03/2012
 * OBJETIVO     : Formulario da CADSPC
 * --------------
 * ALTERAÇÕES   : 12/08/2013 - Alteração da sigla PAC para PA. (Carlos)
 * --------------
 */
 ?>

<form id="frmCadSPC" name="frmCadSPC" class="formulario">

	<fieldset>
	
		<legend> <? echo utf8ToHtml('Devedor/Fiador');  ?> </legend>	
		
		<label for="nrdconta">Devedor:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		<input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />
		<br />
		
		<label for="nrctaavl">Fiador:</label>
		<input type="text" id="nrctaavl" name="nrctaavl" value="<?php echo formataContaDV($nrctaavl) ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		<input type="text" id="nmpriavl" name="nmpriavl" value="<?php echo $nmpriavl ?>" />
		<br />
		
		<label for="cdagenci">PA:</label>
		<input type="text" id="cdagenci" name="cdagenci" value="<?php echo $cdagenci ?>"/>
		<label for="nmresage"></label>
		<input type="text" id="nmresage" name="nmresage" value="<?php echo $nmresage ?>" />
		
	</fieldset>	

	
	<fieldset>
	
		<legend> <? echo utf8ToHtml('Contrato');  ?> </legend>	
		
		<label for="tpctrdev">Tipo:</label>
		<select id="tpctrdev" name="tpctrdev">
		<option value="1" <?php $tpctrdev == '1' ? 'selected' : '' ?> >1-Conta</option>
		<option value="2" <?php $tpctrdev == '2' ? 'selected' : '' ?> >2-Desc Cheques</option>
		<option value="3" <?php $tpctrdev == '3' ? 'selected' : '' ?> >3-Emprestimos</option>
		</select>

		<label for="nrctremp">Contrato:</label>
		<input type="text" id="nrctremp" name="nrctremp" value="<?php echo $nrctremp ?>" />

		<label for="dtvencto">Vencimento:</label>
		<input type="text" id="dtvencto" name="dtvencto" value="<?php echo $dtvencto ?>" />
		<br />
		
		<label for="vldivida">Valor:</label>
		<input type="text" id="vldivida" name="vldivida" value="<?php echo $vldivida ?>" />

		<label for="nrctrspc">Nr Contrato do SPC:</label>
		<input type="text" id="nrctrspc" name="nrctrspc" value="<?php echo $nrctrspc ?>" />

	</fieldset>	


	<fieldset>
	
		<legend> <? echo utf8ToHtml('Inclusao');  ?> </legend>	
		
		<label for="dtinclus">Data:</label>
		<input type="text" id="dtinclus" name="dtinclus" value="<?php echo $dtinclus ?>"/>

		<label for="operador">Operador:</label>
		<input type="text" id="operador" name="operador" value="<?php echo $operador ?>" />

		<label for="tpinsttu">Registro:</label>
		<select id="tpinsttu" name="tpinsttu">
		<option value="1">1-SPC</option>
		<option value="2">2-SERASA</option>
		</select>
		<br />
		
		<label for="dsoberv1"><? echo utf8ToHtml('Obs:');  ?></label>
		<input type="text" id="dsoberv1" name="dsoberv1" value="<?php echo $dsoberv1 ?>" />

	</fieldset>	

	
	<fieldset>
	
		<legend> <? echo utf8ToHtml('Baixa');  ?> </legend>	
		
		<label for="dtdbaixa">Data:</label>
		<input type="text" id="dtdbaixa" name="dtdbaixa" value="<?php echo $dtdbaixa ?>"/>

		<label for="opebaixa">Operador:</label>
		<input type="text" id="opebaixa" name="opebaixa" value="<?php echo $opebaixa ?>" />
		<br />
		
		<label for="dsoberv2"><? echo utf8ToHtml('Obs.:');  ?></label>
		<input type="text" id="dsoberv2" name="dsoberv2" value="<?php echo $dsoberv2 ?>" />


	</fieldset>	
	
</form>	


