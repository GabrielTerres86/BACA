<?php
/*!
 * FONTE        : form_pre_aprovado.php
 * CRIAÇÃO      : Petter Rafael - Envolti
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Formulário da rotina Pre-Aprovado da tela ATENDA
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>
<form name="frmPreAprovado" id="frmPreAprovado" class="formulario" >
  <?php if($xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata != "Cooperado com Pre-Aprovado"){ ?>
  <table cellpadding="0" cellspacing="0" border="0" width="100%">
    <?php if($xmlObjeto->roottag->tags[0]->tags[0]->tags[12]->cdata == 1){ ?>
    <tr>
      <td>
        <fieldset>
          <legend>Mensagem: </legend>
          <p>
            <?php echo $xmlObjeto->roottag->tags[0]->tags[0]->tags[5]->cdata; echo $xmlObjeto->roottag->tags[0]->tags[0]->tags[1]->cdata; ?>
          </p>
        </fieldset>
      </td>
    </tr>
    <?php } ?>
    <tr>
      <td>
        <label for="flgbloq">Bloqueio manual: </label>
        <?
        $valorflg = $xmlObjeto->roottag->tags[0]->tags[0]->tags[0]->cdata;

        if($valorflg == 1){
          ?>
          
        <input type="text" id="flgbloq" name="flgbloq" value="N&atilde;o" />
        <?
        }else if($valorflg == 0){
          ?>
          
        <input type="text" id="flgbloq" name="flgbloq" value="Sim" />
        <?
        }else{
          ?>
          
        <input type="text" id="flgbloq" name="flgbloq" value="N&atilde;o" />
        <?
        }
        ?>

      
      </td>
    </tr>
    <tr>
      <td>
        <label for="vldispon">
          <? echo $xmlValCalc->tags[4]->cdata; ?>:
        
        </label>
        <input type="text" id="vldispon" name="vldispon" />
      </td>
    </tr>
    <tr>
      <td>
        <label for="vlparcel">
          <? echo $xmlValCalc->tags[2]->cdata; ?>:
        
        </label>
        <input type="text" id="vlparcel" name="vlparcel" />
      </td>
    </tr>
    <tr>
      <td>
        <label for="tipoCarga">
          <? echo $xmlValCalc->tags[24]->cdata; ?>:
        
        </label>
        <input type="text" id="tipoCarga" name="tipoCarga" />
      </td>
    </tr>
    <tr>
      <td>
        <fieldset>
          <legend>Valores utilizados para calcular o limite atual:</legend>
          <table>
            <tr>
              <td>
                <label for="vlpotLimMax">
                  <? echo $xmlValCalc->tags[6]->cdata; ?>:
                
                </label>
                <input type="text" id="vlpotLimMax" name="vlpotLimMax" />
              </td>
            </tr>
            <tr>
              <td>
                <label for="vlpotParcMax">
                  <? echo $xmlValCalc->tags[8]->cdata; ?>:
                
                </label>
                <input type="text" id="vlpotParcMax" name="vlpotParcMax" />
              </td>
            </tr>
            <tr>
              <td>
                <label for="nrfimpre">
                  <? echo $xmlValCalc->tags[0]->cdata; ?>:
                
                </label>
                <input type="text" id="nrfimpre" name="nrfimpre" />
              </td>
            </tr>
            <tr>
              <td>
                <label for="sumempr">
                  <? echo $xmlValCalc->tags[28]->cdata; ?>:
                
                </label>
                <input type="text" id="sumempr" name="sumempr" />
              </td>
            </tr>
            <tr>
              <td>
                <label for="vlScr6190">
                  <? echo $xmlValCalc->tags[12]->cdata; ?>:
                
                </label>
                <input type="text" id="vlScr6190" name="vlScr6190" />
              </td>
            </tr>
            <?php if($xmlObjeto->roottag->tags[0]->tags[0]->tags[13]->cdata == 1){ ?>
            <tr>
              <td>
                <label for="vlScr6190Cje">
                  <? echo $xmlValCalc->tags[14]->cdata; ?>:
                
                </label>
                <input type="text" id="vlScr6190Cje" name="vlScr6190Cje" />
              </td>
            </tr>
            <?}?>
            <tr>
              <td>
                <label for="vlopePosScr">
                  <? echo $xmlValCalc->tags[16]->cdata; ?>:
                
                </label>
                <input type="text" id="vlopePosScr" name="vlopePosScr" />
              </td>
            </tr>
            <?php if($xmlObjeto->roottag->tags[0]->tags[0]->tags[13]->cdata == 1){ ?>
            <tr>
              <td>
                <label for="vlopePosScrCje">
                  <? echo $xmlValCalc->tags[18]->cdata; ?>:
                
                </label>
                <input type="text" id="vlopePosScrCje" name="vlopePosScrCje" />
              </td>
            </tr>
            <?}?>
            <tr>
              <td>
                <label for="vlpropAndamt">
                  <? echo $xmlValCalc->tags[20]->cdata; ?>:
                
                </label>
                <input type="text" id="vlpropAndamt" name="vlpropAndamt" />
              </td>
            </tr>
            <?php if($xmlObjeto->roottag->tags[0]->tags[0]->tags[13]->cdata == 1){ ?>
            <tr>
              <td>
                <label for="vlpropAndamtCje">
                  <? echo $xmlValCalc->tags[22]->cdata; ?>:
                
                </label>
                <input type="text" id="vlpropAndamtCje" name="vlpropAndamtCje" />
              </td>
            </tr>
            <?}?>
          </table>
        </fieldset>
      </td>
    </tr>
  </table>
  <?php }else{ ?>
  <div id="semPreAprovado">
    <?php echo $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata; ?>
  </div>
  <?php } ?>
</form>