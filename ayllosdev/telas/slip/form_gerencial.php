<?php
	/*!
    * FONTE        : form_Gerencial.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : form Parametrizar gerenciais da tela SLIP
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
?>

<div id="divGerencial" name="divGerencial">
	<form id="frmGerencial" name="frmGerencial" class="formulario" onSubmit="return false;" style="display:block">
		
		<? 
		    $xml = "<Root>";
		    $xml .= " <Dados>";
		    $xml .= "   <cdcooper>0</cdcooper>";
		    $xml .= "   <flgativo>1</flgativo>";
		    $xml .= " </Dados>";
		    $xml .= "</Root>";

		    $xmlResult = mensageria($xml, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		    $xmlObj = getObjectXML($xmlResult);

		    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		        if ($msgErro == "") {
		            $msgErro = $xmlObj->roottag->tags[0]->cdata;
		        }

		        exibeErroNew($msgErro);
		        exit();
		    }

		    $registros = $xmlObj->roottag->tags[0]->tags;

		    function exibeErroNew($msgErro) {
		        echo 'hideMsgAguardo();';
		        echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
		        exit();
		    }
		 
		 
		?>

	
		<fieldset>				       
			<legend  style="text-align: center" >Selecione a Cooperativa</legend>
	        <div id="divCooper" style="left-padding:2px;display: flex; flex-direction: row;justify-content: center;align-items: center">	            
	            
	            <select id="nmrescop" name="nmrescop" class="campo" style="margin-top:6px">             
	            <?php
	            foreach ($registros as $r) {
	                
	                if ( getByTagName($r->tags, 'cdcooper') <> '' ) {
	            ?>
	                <option value="<?= getByTagName($r->tags, 'cdcooper'); ?>" 
	                        <?  if (getByTagName($r->tags, 'cdcooper')== $glbvars['cdcooper']){ echo ' selected';} ?> > <?= getByTagName($r->tags, 'nmrescop'); ?></option> 
	                
	            <?php
	                }
	            }
	            ?>
	            </select>

	            <a href="#" class="botao" id="btnCopOk" name="btnCopOK">OK</a>
	        </div>
	    </fieldset>  
				 		
		<fieldset id="fsGerencial" style="display:none">
		<legend style="text-align: center" ><? echo utf8ToHtml("Parametrização Gerencial") ?></legend>								    		
			
			<div id="incGerencial">
				<label for="cdgerencial"><? echo utf8ToHtml("Gerencial:") ?></label>
				<input name="cdgerencial" type="text"  id="cdgerencial" class="inteiro campo" style="width: 55px;">
	            
			 	<a href="#" class="botao" id="btIncluirGer" name="btIncluirGer" style = "text-align:right;">Incluir</a>
		    </div>

			<div id="tabGerencial">
				<fieldset id="fstabGerencial" style="display:block">			
				<div class="divRegistros">
					
					<table class="tituloRegistros" id="tbGerencial">
						<thead>								
							<tr>
								<th> <? echo utf8ToHtml("Ati./Des.");?></th>									
							    <th><? echo utf8ToHtml("Gerencial");?></th>																					
							</tr>								
						</thead>
						<tbody>
						</tbody>
					</table>		
				
				</div> 
			   </fieldset>			
			</div>	        
		</fieldset>
	</form>		
</div>	