<?php
/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 27/11/2018;
 * Ultima alteração:
 * 
 * Alterações:
 */
?>
<div class="divRegistros">	
	<table id='tabelaTelaPrincipal'>
		<thead>
			<tr>
				<th><? echo utf8ToHtml('Data Proposta'); ?></th>
				<th><? echo utf8ToHtml('Data Efetivação'); ?></th>
				<th><? echo utf8ToHtml('Número do Contrato'); ?></th>
				<th><? echo utf8ToHtml('Valor do Limite de Crédito'); ?></th>
				<th><? echo utf8ToHtml('Taxa'); ?></th>
				<th><? echo utf8ToHtml('Vigência do Contrato'); ?></th>
				<th><? echo utf8ToHtml('Data da Renovação'); ?></th>
				<th><? echo utf8ToHtml('Situação'); ?></th>
			</tr>
		</thead>
		<tbody>
			<?php
			if(isset($xmlLimites->inf[0]->{"insitlim"})){
				foreach($xmlLimites->inf as $limite){
				?>
					<tr data-lfgsitua='<?php echo $limite->{'lfgsitua'}; ?>'
						data-nrctrlim='<?php echo $limite->{'nrctrlim'}; ?>'
					>
						<td><?php echo $limite->{'dtpropos'}; ?></td><?php  //dtpropos -> Data Proposta ?>
						<td><?php echo $limite->{'dtinivig'}; ?></td><?php  //dtinivig -> Data Efetivação ?>
						<td><?php echo $limite->{'nrctrlim'}; ?></td><?php  //nrctrlim -> Número do Contrato?>
						<td><?php echo $limite->{'vllimite'}; ?></td><?php  //vllimite -> Valor do Limite de Crédito ?>
						<td><?php echo $limite->{'txmensal'}; ?>%</td><?php //txmensal -> Taxa ?>
						<td><?php echo $limite->{'dtfimvig'}; ?></td><?php  //dtfimvig -> Vigência do Contrato ?>
						<td><?php echo $limite->{'dtrenova'}; ?></td><?php  //dtrenova -> Data da Renovação ?>
						<td><?php echo $limite->{'insitlim'}; ?></td><?php  //insitlim -> Situação (ativo|pausado(proposto)) ?>
					</tr>
				<?php
				}
			}
			?>
		</tbody>
	</table>
</div>

<!-- Atribuir valores padroes para aux_limites -->
<script>
	var aux_hasAtivo = false;
	var aux_hasEstudo = false;
	<?php
	foreach($xmlLimites->inf as $limite){
		?>
		var_globais.inpessoa = "<?php echo $limite->{'inpessoa'} ?>";
		<?php
		if($limite->{"lfgsitua"} != "1"){

			if($limite->{'nrctrlim'} != ""){
				?>
					aux_hasAtivo = true;
				<?php
			}
			?>
			aux_limites.ativo.dtpropos = "<?php echo $limite->{'dtpropos'}; ?>";
			aux_limites.ativo.dtinivig = "<?php echo $limite->{'dtinivig'}; ?>";
			aux_limites.ativo.nrctrlim = "<?php echo $limite->{'nrctrlim'}; ?>";
			aux_limites.ativo.vllimite = "<?php echo $limite->{'vllimite'}; ?>";
			aux_limites.ativo.txmensal = "<?php echo $limite->{'txmensal'}; ?>";
			aux_limites.ativo.dtfimvig = "<?php echo $limite->{'dtfimvig'}; ?>";
			aux_limites.ativo.dtrenova = "<?php echo $limite->{'dtrenova'}; ?>";
			aux_limites.ativo.insitlim = "<?php echo $limite->{'insitlim'}; ?>";
			aux_limites.ativo.lfgsitua = "<?php echo $limite->{'lfgsitua'}; ?>";
			aux_limites.ativo.inpessoa = "<?php echo $limite->{'inpessoa'}; ?>";
			aux_limites.ativo.qtdiavig = "<?php echo $limite->{'qtdiavig'}; ?>";
			aux_limites.ativo.cddlinha = "<?php echo $limite->{'cddlinha'}; ?>";
			aux_limites.ativo.dsdlinha = "<?php echo $limite->{'dsdlinha'}; ?>";
			aux_limites.ativo.nivrisco = "<?php echo $limite->{'nivrisco'}; ?>";
			aux_limites.ativo.txjurfix = "<?php echo $limite->{'txjurfix'}; ?>";

			//Campos Rating
			aux_limites.ativo.nrgarope = "<?php echo $limite->{'nrgarope'}; ?>";
			aux_limites.ativo.nrinfcad = "<?php echo $limite->{'nrinfcad'}; ?>";
			aux_limites.ativo.nrliquid = "<?php echo $limite->{'nrliquid'}; ?>";
			aux_limites.ativo.nrpatlvr = "<?php echo $limite->{'nrpatlvr'}; ?>";
			aux_limites.ativo.nrperger = "<?php echo $limite->{'nrperger'}; ?>";
			<?php
		}else if($limite->{"lfgsitua"} == "1"){
			?>
			aux_hasEstudo = true;
			aux_limites.pausado.dtpropos = "<?php echo $limite->{'dtpropos'}; ?>";
			aux_limites.pausado.dtinivig = "<?php echo $limite->{'dtinivig'}; ?>";
			aux_limites.pausado.nrctrlim = "<?php echo $limite->{'nrctrlim'}; ?>";
			aux_limites.pausado.vllimite = "<?php echo $limite->{'vllimite'}; ?>";
			aux_limites.pausado.txmensal = "<?php echo $limite->{'txmensal'}; ?>";
			aux_limites.pausado.dtfimvig = "<?php echo $limite->{'dtfimvig'}; ?>";
			aux_limites.pausado.dtrenova = "<?php echo $limite->{'dtrenova'}; ?>";
			aux_limites.pausado.insitlim = "<?php echo $limite->{'insitlim'}; ?>";
			aux_limites.pausado.lfgsitua = "<?php echo $limite->{'lfgsitua'}; ?>";
			aux_limites.pausado.inpessoa = "<?php echo $limite->{'inpessoa'}; ?>";
			aux_limites.pausado.qtdiavig = "<?php echo $limite->{'qtdiavig'}; ?>";
			aux_limites.pausado.cddlinha = "<?php echo $limite->{'cddlinha'}; ?>";
			aux_limites.pausado.dsdlinha = "<?php echo $limite->{'dsdlinha'}; ?>";
			aux_limites.pausado.nivrisco = "<?php echo $limite->{'nivrisco'}; ?>";
			aux_limites.pausado.txjurfix = "<?php echo $limite->{'txjurfix'}; ?>";

			//Campos Rating
			aux_limites.pausado.nrgarope = "<?php echo $limite->{'nrgarope'}; ?>";
			aux_limites.pausado.nrinfcad = "<?php echo $limite->{'nrinfcad'}; ?>";
			aux_limites.pausado.nrliquid = "<?php echo $limite->{'nrliquid'}; ?>";
			aux_limites.pausado.nrpatlvr = "<?php echo $limite->{'nrpatlvr'}; ?>";
			aux_limites.pausado.nrperger = "<?php echo $limite->{'nrperger'}; ?>";
			<?php
		}
	}
	?>
</script>