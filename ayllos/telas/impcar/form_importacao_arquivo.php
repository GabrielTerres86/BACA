<? 
/*!
 * FONTE        : form_impar.php
 * CRIA��O      : James Prust Junior
 * DATA CRIA��O : 23/03/2016
 * OBJETIVO     : Formulario de importacao do arquivo de cartao
 * --------------
 * ALTERA��ES   : 
 * --------------
 */	
?>
<form id="frmImportarArquivo" name="frmImportarArquivo" class="formulario">
	<fieldset>
		<div id="divImportarArquivos">
			<div>
				<fieldset>
					<legend>Arquivos pendentes</legend>
						
					<div id="divArquivos" class="divRegistros">
						<table width="100%">
							<thead>
								<tr>
									<th><?php echo utf8ToHtml('Bandeira') ?></th>								
									<th><?php echo utf8ToHtml('Arquivo') ?></th>								
								</tr>
							</thead>
							<tbody>
							<?php
							foreach ($aRegistros as $oTag) {
							?>
								<tr>
									<td><?= getByTagName($oTag->tags,'NMBANDEI') ?></td>
									<td><?= getByTagName($oTag->tags,'NMARQUIV') ?></td>
								</tr>
							<?php
							}
							?>
							</tbody>
						</table>
					</div>
				</fieldset>
			</div>
			<div>	
				<label for="dsstatus">Status: </label>	
				<input type="text" id="dsstatus" name="dsstatus" value="<?= $situacao ?>"/>
			</div>	
		</div>
  	</fieldset>		
</form>