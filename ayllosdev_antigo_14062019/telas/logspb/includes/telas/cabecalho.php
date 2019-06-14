<?php
/*
Autor: Bruno Luiz Katzjarowski - Mout's
Data: 01/11/2018
Ultima alteração:

Alterações:
	1 - Alterar formulario para cddopcao
*/ 

/* Valida opções da tela */
$validaOpcaoC = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'],"C");
$validaOpcaoM = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'],"M");
$validaOpcaoS = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'],"S");

?>

<form id="formCddopcao" name="formCddopcao" class="formulario cabecalho" style="display: block;">	
	
	<div>
		<label for="cddopcao" class="rotulo txtNormalBold"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
		<select id="cddopcao" name="cddopcao" class="campoTelaSemBorda" tabindex="-1" disabled="">
		<?php
				if($validaOpcaoC == ""){
					?>
					<option value="C" >C - Consulta de transa&ccedil;&otilde;es no SPB</option>
					<?php
				}
				
				if($validaOpcaoM == ""){
					?>
					<option value="M">M - Consulta de transa&ccedil;&otilde;es de cr&eacute;dito migradas no SPB</option>
					<?php
				}
				
				if($validaOpcaoS == ""){
					?>
					<option value="S">S - Consulta TEDs Sicredi Consignado</option>
					<?php
				}
				?>
		</select>
		
		<a href="#" class="botao" id="btSelecionaOpcao" style="text-align: right;">OK</a>
		<!--<a href="#" class="botao" id="btTeste" style="text-align: right;">TESTES</a>-->
		<br style="clear:both">	
	</div>
</form>

<form name="frmLogSPB" id="frmLogSPB" class="formulario condensado cabecalho" method="POST" action='imprimir_csv.php' >
    <input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
	<input type="hidden" name="aux_cddopcao" id="aux_cddopcao" value="" />
	<input type="hidden" name="aux_nrregist" id="aux_nrregist" value="" />
	
    <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		<br style="clear:both" />
				
	
		<!-- FILTRO -->
	    <fieldset class="logspb">
			<legend>Filtro</legend>                                                  
		
			<div class='bloco' id='blocoOpcao1'>

				<div>
					<label for='selCooperativas' class='rotulo txtNormalBold'>Cooperativa:</label>
					<select id='selCooperativas' name='selCooperativas' class='FirstInput campo'>
					</select>
				</div>

				<div style='width: 100%;'>
					<label for='selTipo' class='rotulo txtNormalBold'>Tipo:</label>
					<select id='selTipo' name='selTipo' class='campo'>
					</select>
				</div>

				<div>
					<label for='textDataDe' class='rotulo txtNormalBold'>Per&iacute;odo:</label>
					<input type="text" id='textDataDe' name='textDataDe' value='' class='campo data'/>


					<label for='textDataAte' id='labelTextDataAte' class='rotulo-linha txtNormalBold'>a</label>
					<input type="text" id='textDataAte' name='textDataAte' value='' class='campo data' />
				</div>

				<div>
					<label for='textValorDe' class='rotulo txtNormalBold'>Valor:</label>
					<input type="text" id='textValorDe' name='textValorDe' value='' class='campo moeda'/>


					<label for='textValorAte' id='labelTextValorAte' class='rotulo-linha txtNormalBold'>a</label>
					<input type="text" id='textValorAte' name='textValorAte' value='' class='campo moeda' />
				</div>	

			</div>

			<div class='bloco' id='blocoOpcao2'>
				<div>
					<label for='selContaDv' class='rotulo txtNormalBold'>Conta/dv:</label>
					<input type='text' id='selContaDv' name='selContaDv' class='campo' />
				</div>

				<div>
					<label for='selOrigem' class='rotulo txtNormalBold'>Origem:</label>
					<select id="selOrigem" name='selOrigem' class="campo"></select>
				</div>

				<div>
					<label for='selIfContraparte' class='rotulo txtNormalBold'>IF contraparte:</label>
					<select id="selIfContraparte" name='selIfContraparte' class="campo"></select>
				</div>
			</div>


	    </fieldset> <!-- FIM FILTRO -->

	<!-- DIV BOTOES -->
	
	<div id="divBotoesFiltroBuscaGrupo" style="margin-top:5px; margin-bottom :10px; text-align: center;">
	
		<a href="#" class="botao" id="btVoltar"  >Voltar</a>
		<a href="#" class="botao" id="btConsultar" >Prosseguir</a>	

	</div>
	
	</br>

</form>