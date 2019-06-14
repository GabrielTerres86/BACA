<?
/* 
 * FONTE        : imprimir.php
 * CRIAÇÃO      : Gabriel Ramirez
 * DATA CRIAÇÃO : 13/04/2011 
 * OBJETIVO     : Mostrar a tela de impressao.
 * 
 * ALTERACOES   :
*/


?>

<form action="<?php echo $UrlSite; ?>dda/impressao_titulos.php" name="frmTitulos" id="frmTitulos" class="formulario" method="post" >

<input type="hidden" id="nrdconta" name="nrdconta" value="">	
<input type="hidden" id="idseqttl" name="idseqttl" value="">	 

</form>

	
<div id="divImpressoes" style="with:400px;" >	
	<div id="adesao"   style="width:98px" > Termo de Adesao  </div>
	<div id="exclusao" style="width:100px" > Termo de Exclusao</div>
	<div id="titulos"  style="width:90px" > Titulos Bloqueados  </div>
</div>


<script type="text/javascript">	

  controlaLayout();
  
</script>