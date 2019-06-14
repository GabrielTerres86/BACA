<?
	/************************************************************************
	 Fonte: criticas_bordero.php                                        
	 Autor: Luis Fernando (GFT)
	 Data : 20/07/2018
	                                                                  
	 Objetivo  : Traz o layout das criticas que sao mostradas na tela de visualizacao de borderos. Depende te um objeto getClassXML

	************************************************************************/
	
	/*Precisa de uma variavel $dados que vem do getClassXML*/
    $bordero = $dados->findFirst("bordero");
    $cedente = $dados->findFirst("cedente");
    // var_dump($cedente);
    if($bordero){
		$criticasBordero = $bordero->find("critica");
		$criticasBordero = $criticasBordero ? $criticasBordero : array();
	}
    if($cedente){
		$criticasCedente = $cedente->find("critica");
		$criticasCedente = $criticasCedente ? $criticasCedente : array();
	}
?>
<form class="formulario">
	<? if(count($criticasBordero)>0) {?>
	<fieldset>
		<legend>Cr&iacute;ticas de Border&ocirc;</legend>
		<div>
			<div id="divCriticaBordero">
				<div class="divRegistrosTitulosSelecionados">
					<table class="tituloRegistros divRegistros">
						<thead>
							<tr>
								<th width="50%">Cr&iacute;tica</th>
								<th width="50%">Valor</th>
							</tr>
						</thead>
						<tbody>
							<?php foreach($criticasBordero AS $c) {?>
								<tr>
									<td style="border-right:1px dotted #999;"><?php echo $c->dsc; ?></td>
									<td style="border-right:1px dotted #999;"><?php echo $c->vlr;?></td>
								</tr>
							<?} // Fim do foreach ?>	
						</tbody>
					</table>
				</div><!-- divRegistrosTitulosSelecionados -->
			</div><!-- divCritica -->
		</div>
	</fieldset>
	<?}?>
	<? if(count($criticasCedente)>0) {?>
	<fieldset>
		<legend>Cr&iacute;ticas do Cedente</legend>
		<div>
			<div id="divCriticaCedente">
				<div class="divRegistrosTitulosSelecionados">
					<table class="tituloRegistros divRegistros">
						<thead>
							<tr>
								<th width="50%">Cr&iacute;tica</th>
								<th width="50%">Valor</th>
							</tr>
						</thead>
						<tbody>
							<?php foreach($criticasCedente AS $c) {?>
								<tr>
									<td style="border-right:1px dotted #999;"><?php echo $c->dsc; ?></td>
									<td style="border-right:1px dotted #999;"><?php echo $c->vlr;?></td>
								</tr>
							<?} // Fim do foreach ?>	
						</tbody>
					</table>
				</div><!-- divRegistrosTitulosSelecionados -->
			</div><!-- divCritica -->
		</div>
	</fieldset>
	<?}?>
</form>
<script>
	//criticas
	formataTabelaCriticas($("#divCriticaCedente"));
	formataTabelaCriticas($("#divCriticaBordero"));
</script>