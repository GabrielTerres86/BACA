<?php
/*******************************************************************************************
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 25/10/2011
 * OBJETIVO     : Cabeçalho para a tela VERPRO              Última alteração: 23/03/2017
 * --------------
 * ALTERAÇÕES   :
 *                  16/01/2013 - Daniel (CECRED) : Implantacao novo layout.

                    09/10/2014 - Incluido o tipo "Resgate de aplicacao"
                                 (Adriano).

 *                  28/08/2015 - Inclusao novo tipo protocolo => 13 - GPS
                                 (Guilherme/SUPERO)

                    05/07/2016 - Inclusao novo tipo protocolo => 15 - Pagamento Débito Automático
                                 PRJ320 - Oferta DebAut(Odirlei - AMcom)
								 
					05/07/2016 - Inclusão protocolo 16, 17, 18, 19 (PRJ338 - Lucas Lunelli)
					
					23/03/2017 - Inclusão protocolo 20. (PRJ321 - Reinert)
          
					02/01/2018 - Inclusão protocolos 24 - FGTS e 23 - DAE (PRJ406).
 *********************************************************************************************/
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none" >

    <label for="nrdconta">Conta:</label>
    <input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta; ?>" />
    <a style="margin-top:5px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
    <a href="#" class="botao" id="btnOK">OK</a>

    <label for="datainic">Data Inicial:</label>
    <input type="text" id="datainic" name="datainic" value="<? echo $datainic ?>" />

    <label for="datafina">Data Final:</label>
    <input type="text" id="datafina" name="datafina" value="<? echo $datafina ?>" />

    <label for="cdtippro">Tipo:</label>
    <select type="text" id="cdtippro" name="cdtippro">
    <option value="0" <?php echo $cdtippro == '0' ? 'selected' : '' ?>>0 - Todos</option>
    <option value="1" <?php echo $cdtippro == '1' ? 'selected' : '' ?>>1 - Transferencia</option>
    <option value="2" <?php echo $cdtippro == '2' ? 'selected' : '' ?>>2 - Pagamento</option>
    <option value="3" <?php echo $cdtippro == '3' ? 'selected' : '' ?>>3 - Capital</option>
    <option value="4" <?php echo $cdtippro == '4' ? 'selected' : '' ?>>4 - Credito de Salario</option>
    <option value="5" <?php echo $cdtippro == '5' ? 'selected' : '' ?>>5 - Deposito TAA</option>
    <option value="6" <?php echo $cdtippro == '6' ? 'selected' : '' ?>>6 - Pagamento TAA</option>
    <option value="7" <?php echo $cdtippro == '7' ? 'selected' : '' ?>>7 - Arquivo Remessa</option>
    <option value="9" <?php echo $cdtippro == '9' ? 'selected' : '' ?>>9 - TED</option>
    <option value="10" <?php echo $cdtippro == '10' ? 'selected' : '' ?>>10 - Aplicacao</option>
    <option value="12" <?php echo $cdtippro == '12' ? 'selected' : '' ?>>12 - Resgate de Aplicacao</option>
    <option value="13" <?php echo $cdtippro == '13' ? 'selected' : '' ?>>13 - GPS (Previd&ecirc;ncia Social) </option>
	<option value="14" <?php echo $cdtippro == '14' ? 'selected' : '' ?>><?php echo utf8ToHtml('14 - Serviços Cooperativos') ?> </option>
    <option value="15" <?php echo $cdtippro == '15' ? 'selected' : '' ?>> <?php echo utf8ToHtml('15 - Pagamento Débito Automático') ?> </option>
    <option value="16" <?php echo $cdtippro == '16' ? 'selected' : '' ?>>16 - DARF</option>
    <option value="17" <?php echo $cdtippro == '17' ? 'selected' : '' ?>>17 - DAS</option>
    <option value="18" <?php echo $cdtippro == '18' ? 'selected' : '' ?>>18 - Agendamento DARF</option>
    <option value="19" <?php echo $cdtippro == '19' ? 'selected' : '' ?>>19 - Agendamento DAS</option>
    <option value="20" <?php echo $cdtippro == '20' ? 'selected' : '' ?>>20 - Recarga de celular</option>
	<option value="21" <?php echo $cdtippro == '21' ? 'selected' : '' ?>>21 - Operador</option>
    <option value="23" <?php echo $cdtippro == '23' ? 'selected' : '' ?>>23 - DAE</option>
    <option value="24" <?php echo $cdtippro == '24' ? 'selected' : '' ?>>24 - FGTS</option>
    </select>

    <br />

    <label for="nmprimtl">Titular:</label>
    <input name="nmprimtl" id="nmprimtl" type="text" value="<? echo $nmprimtl ?>" />

    <br style="clear:both;" />

</form>

<div id="divBotoes" style="margin-bottom:10px;display:none">
    <a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
    <a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">Prosseguir</a>
</div>

<script>
    highlightObjFocus( $('#frmCab') );
</script>
