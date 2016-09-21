<? 
 /*!
 * FONTE        : form_fluxo.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 28/12/2011 											ÚLTIMA ALTERAÇÃO: 21/03/2016
 * OBJETIVO     : Formulário de exibição do fluxo
 * --------------
 * ALTERAÇÕES   : 01/08/2012 - Incluido novos forms(Entrada,Saida,Resultado) e feito controle de tela (Tiago);
 *				  22/08/2012 - Ajuste referente ao projeto Fluxo Financeiro (Adriano).
 *                18/03/2016 - Ajustes de layout (Adriano);
				  21/03/2016 - Ajuste layout, valores negativos (Adriano)
 * --------------
 */	
?>


<form name="frmFluxo" id="frmFluxo" class="formulario" onSubmit="return false;" >		
			
	<?php 
		/*SINGULAR*/
		if($cdmovmto == "E"){
			include('form_fluxo_entrada.php'); 	
		}else if($cdmovmto == "S"){
			include('form_fluxo_saida.php');
		}else if($cdmovmto == "R"){
			include('form_fluxo_resultado.php');
		}
		
		/*CENTRAL*/
		if($cdmovmto == "E"){
			include('form_fluxo_entrada_cecred.php');
		}else if($cdmovmto == "S"){
			include('form_fluxo_saida_cecred.php');
		}else if($cdmovmto == "R"){
			include('form_fluxo_resultado_cecred.php');
		}else if($cdmovmto == "A"){
			include('form_fluxo_investimento_cecred.php');
		}
		
	?>

</form>

<div id="divBotoesFluxo" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
</div>


<script>

	$(document).ready(function() {
	
		var aux_cdcooper = <? echo $glbvars["cdcooper"]; ?>;
		
		/*SINGULAR*/
		$('#fsetsaida').hide();
		$('#fsetentrada').hide();					
		$('#fsetresultado').hide();		
		
		/*CENTRAL*/
		$('#fsetentradacecred').hide();
		$('#fsetsaidacecred').hide();
		$('#fsetresultadocecred').hide();
		$('#fsetinvestcecred').hide();
		
		if(aux_cdcooper == 3){
			/********CENTRAL*********/
			switch(cCdmovmto.val()){
				case "E":
					$('#fsetentradacecred').show();
					break;
				case "S":
					$('#fsetsaidacecred').show();
					break;
				case "R":
					$('#fsetresultadocecred').show();
					break;
				case "A":
					$('#fsetinvestcecred').show();
					break;
			}
		}else{		
			/**********SINGULARES*************/
			if(cCdmovmto.val() == "E"){
				$('#fsetentrada').show();			
			}else{
				if(cCdmovmto.val() == "S"){
					$('#fsetsaida').show();
				}else{
					if(cCdmovmto.val() == "R"){
						$('#fsetresultado').show();					
					}			
				}	
			}
		}
	});
</script>
