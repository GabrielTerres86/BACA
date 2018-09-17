<?php
	/*!
	* FONTE        : form_parmon.php
	* CRIAÇÃO      : Jorge I. Hamaguchi
	* DATA CRIAÇÃO : 14/08/2013 
	* OBJETIVO     : Form da tela PARMON
	* --------------
	* ALTERAÇÕES   : 20/10/2014 - Novos campos. Chamado 198702 (Jonata-RKAM).
	*
	*                06/04/2016 - Adicionado campos de TED. (Jaison/Marcos - SUPERO)
	*
	*                24/05/2016 - Inclusão do novo parâmetro (flmntage) de monitoração de agendamento (Carlos)
	*
	*				 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	*
	*				 31/10/2017 - Ajuste tela prevencao a lavagem de dinheiro - Melhoria 458 (junior Mouts)
	*
	*                16/05/2017 - Ajustes prj420 - Resolucao - Heitor (Mouts)
	* --------------
	*/

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<div>
  <form id="frmparmon" name="frmparmon" style="display:none" class="formulario" onsubmit="return false;">
    <fieldset>
      <input type="hidden" id="dsestted" />
      <div id="divFraude" style="display:none">
        <fieldset>
          <legend>Pagamentos</legend>
          <table width="100%">
            <tr>
              <td>
                <label for="vlinimon">Valor inicial monitora&ccedil;&atilde;o:</label>
                <input type="text" id="vlinimon" name="vlinimon" value=""
                <? echo $vlinimon ?>" />				
				
              </td>
            </tr>
            <tr>
              <td>
                <label for="vllmonip">Valor limite valida&ccedil;&atilde;o IP:</label>
                <input type="text" id="vllmonip" name="vllmonip" value=""
                <? echo $vllmonip ?>" />
				
              </td>
            </tr>
          </table>
        </fieldset>
        <fieldset>
          <legend> Saque + Transfer&ecirc;ncia </legend>
          <table width="100%">
            <tr>
              <td>
                <label for="vlinisaq">Valor inicial do saque: </label>
                <input type="text" id="vlinisaq" name="vlinisaq" value=""
                <? echo $vlinisaq ?>" />				
				
              </td>
            </tr>
            <tr>
              <td>
                <label for="vlinitrf">Valor inicial da transfer&ecirc;ncia: </label>
                <input type="text" id="vlinitrf" name="vlinitrf" value=""
                <? echo $vlinitrf ?>" />
				
              </td>
            </tr>
          </table>
        </fieldset>
        <fieldset>
          <legend> Saque Individual </legend>
          <table width="100%">
            <tr>
              <td>
                <label for="vlsaqind">Valor inicial do saque: </label>
                <input type="text" id="vlsaqind" name="vlsaqind" value=""
                <? echo $vlinisaq ?>" />				
				
              </td>
            </tr>
            <tr>
              <td>
                <label for="insaqlim">Saque deve ser o limite da conta: </label>
                <input type="radio" name="insaqlim" id="insaqlim_1" value="1" style="margin-left: 20px;">
                  <label id="insaqlim_sim">Sim</label>
                  <input type="radio" name="insaqlim" id="insaqlim_0" value="0" style="margin-left: 20px;" >
                    <label id="insaqlim_nao">N&atilde;o</label>
                  </td>
            </tr>
          </table>
        </fieldset>
        <fieldset>
          <legend> Bloqueio Cart&atilde;o </legend>
          <table width="100%">
            <tr>
              <td>
                <label for="inaleblq">Alertar cart&atilde;o bloqueado: </label>
                <input type="radio" name="inaleblq" id="inaleblq_1" value="1" style="margin-left: 20px;">
                  <label id="inaleblq_sim">Sim</label>
                  <input type="radio" name="inaleblq" id="inaleblq_0" value="0" style="margin-left: 20px;" >
                    <label id="inaleblq_nao">N&atilde;o</label>
                  </td>
            </tr>
          </table>
        </fieldset>
        <fieldset>
          <legend> TED </legend>
          <table width="100%">
            <tr>
              <td>
                <label for="vlmnlmtd">Limite TED superior a: </label>
                <input type="text" id="vlmnlmtd" name="vlmnlmtd" value=""
                <? echo $vlmnlmtd ?>" />				
				
              </td>
            </tr>
            <tr>
              <td>
                <label for="vlinited">Valor m&iacute;nimo de TED: </label>
                <input type="text" id="vlinited" name="vlinited" value=""
                <? echo $vlinited ?>" />				
				
              </td>
            </tr>
            <tr>
              <td>
                <label for="flmstted">Monitorar TEDs mesma Titularidade: </label>
                <input type="radio" name="flmstted" id="flmstted_1" value="1" style="margin-left: 20px;">
                  <label id="flmstted_sim">Sim</label>
                  <input type="radio" name="flmstted" id="flmstted_0" value="0" style="margin-left: 20px;" >
                    <label id="flmstted_nao">N&atilde;o</label>
                  </td>
            </tr>
            <tr>
              <td>
                <label for="flnvfted">Monitorar somente novos favorecidos: </label>
                <input type="radio" name="flnvfted" id="flnvfted_1" value="1" style="margin-left: 20px;">
                  <label id="flnvfted_sim">Sim</label>
                  <input type="radio" name="flnvfted" id="flnvfted_0" value="0" style="margin-left: 20px;" >
                    <label id="flnvfted_nao">N&atilde;o</label>
                  </td>
            </tr>
            <tr>
              <td>
                <label for="flmobted">Monitoramento Mobile: </label>
                <input type="radio" name="flmobted" id="flmobted_1" value="1" style="margin-left: 20px;">
                  <label id="flmobted_sim">Sim</label>
                  <input type="radio" name="flmobted" id="flmobted_0" value="0" style="margin-left: 20px;" >
                    <label id="flmobted_nao">N&atilde;o</label>
                  </td>
            </tr>
            <tr>
              <td>
                <label for="flmntage">Monitorar agendamentos:</label>
                <input type="radio" name="flmntage" id="flmntage_1" value="1" style="margin-left: 20px;">
                  <label id="flmntage_sim">Sim</label>
                  <input type="radio" name="flmntage" id="flmntage_0" value="0" style="margin-left: 20px;" >
                    <label id="flmntage_nao">N&atilde;o</label>
                  </td>
            </tr>
            <tr>
              <td>
                <fieldset>
                  <legend> UFs para monitoramento </legend>
                  <table width="100%">
                    <tr id="linAddUF">
                      <td>
                        <label for="nmuf">UF:</label>
                        <select name="nmuf" id="nmuf" class="campo"></select>
                        <a href="#" class="botao" id="btAdicionar" onclick="incluirEstado(); return false;" style="margin-left:10px;">Adicionar</a>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <label>UFs monitoradas:</label>
                        <table cellpadding="5" cellspacing="5">
                          <tbody id="listUF"></tbody>
                        </table>
                      </td>
                    </tr>
                  </table>
                </fieldset>
              </td>
            </tr>
          </table>
        </fieldset>
      </div>
      <!--PLD-->
      <div id="divPLD" style="display:none">
        <fieldset>
          <legend> Alertas </legend>
          <table width="100%">
            <!--diario-->
            <tr>
              <td>
                <label class="lbPrincipal">Quantidade de vezes a renda do cooperado para alerta di&aacute;rio:</label>
              </td>
            </tr>
            <tr>
              <td>
                <label for="qtrendadiariopf"  class="txtPLD">Pessoa F&iacute;sica:</label>
                <input type="text" id="qtrendadiariopf" class="txtPLDInt" name="qtrendadiariopf" value=""
                <? echo $qtrendadiariopf ?>" />
						
              </td>
            </tr>
            <tr>
              <td>
                <label for="qtrendadiariopj" class="txtPLD">Pessoa Jur&iacute;dica:</label>
                <input type="text" id="qtrendadiariopj" class="txtPLDInt" name="qtrendadiariopj" value=""
                <? echo $qtrendadiariopj ?>" />
						
              </td>
            </tr>

            <tr>
              <td>
                <label class="lbPrincipal">Total de cr&eacute;ditos pelo cooperado para alerta di&aacute;rio:</label>
              </td>
            </tr>
            <tr>
              <td>
                <label for="vlcreditodiariopf" class="txtPLD">Pessoa F&iacute;sica:</label>
                <input type="text" id="vlcreditodiariopf" name="vlcreditodiariopf" value=""
                <? echo $vlcreditodiariopf ?>" />
						
              </td>
            </tr>
            <tr>
              <td>
                <label for="vlcreditodiariopj" class="txtPLD">Pessoa Jur&iacute;dica:</label>
                <input type="text" id="vlcreditodiariopj" name="vlcreditodiariopj" value=""
                <? echo $vlcreditodiariopj ?>" />
						
              </td>
            </tr>
            <!--mensal-->
            <tr>
              <td>
                <label class="lbPrincipal">Quantidade de vezes a renda do cooperado para alerta mensal:</label>
              </td>
            </tr>
            <tr>
              <td>
                <label for="qtrendamensalpf" class="txtPLD">Pessoa F&iacute;sica:</label>
                <input type="text" id="qtrendamensalpf" class="txtPLDInt" name="qtrendamensalpf" value=""
                <? echo $qtrendamensalpf ?>" />
						
              </td>
            </tr>
            <tr>
              <td>
                <label for="qtrendamensalpj" class="txtPLD">Pessoa Jur&iacute;dica:</label>
                <input type="text" id="qtrendamensalpj" class="txtPLDInt" name="qtrendamensalpj" value=""
                <? echo $qtrendamensalpj ?>" />
						
              </td>
            </tr>

            <tr>
              <td>
                <label class="lbPrincipal">Total de cr&eacute;ditos pelo cooperado para alerta mensal:</label>
              </td>
            </tr>
            <tr>
              <td>
                <label for="vlcreditomensalpf" class="txtPLD">Pessoa F&iacute;sica:</label>
                <input type="text" id="vlcreditomensalpf" name="vlcreditomensalpf" value=""
                <? echo $vlcreditomensalpf ?>" />
						
              </td>
            </tr>
            <tr>
              <td>
                <label for="vlcreditomensalpj" class="txtPLD">Pessoa Jur&iacute;dica:</label>
                <input type="text" id="vlcreditomensalpj" name="vlcreditomensalpj" value=""
                <? echo $vlcreditomensalpj ?>" />
						
              </td>
            </tr>

            <tr>
              <td>
                <label for="inrendazerada" class="txtPLD">Renda zerada:</label>
                <input type="checkbox" id="inrendazerada" name="inrendazerada" value=""
                <? echo $inrendazerada ?>" />
						
              </td>
            </tr>

          </table>
        </fieldset>
        <fieldset>
          <legend>Monitoramento</legend>
          <table width="100%">
            <tr>
              <td>
                <label for="vllimitesaque">Somat&oacute;ria valor saques em esp&eacute;cie:</label>
                <input type="text" id="vllimitesaque" name="vllimitesaque" value=""
                <? echo $vllimitesaque ?>" />
						
              </td>
            </tr>

            <tr>
              <td>
                <label for="vllimitedeposito">Somat&oacute;ria dep&oacute;sito em esp&eacute;cie:</label>
                <input type="text" id="vllimitedeposito" name="vllimitedeposito" value=""
                <? echo $vllimitedeposito ?>" />
						
              </td>
            </tr>

            <tr>
              <td>
                <label for="vllimitepagamento" class="lbAjuste">Somat&oacute;ria de pagamentos em esp&eacute;cie:</label>
                <input type="text" id="vllimitepagamento" name="vllimitepagamento" value=""
                <? echo $vlprovpagtoespecie ?>" />
						
              </td>
            </tr>

            <tr>
              <td>
                <label for="vlprovisaoemail">Valor de provis&atilde;o para envio de e-mail:</label>
                <input type="text" id="vlprovisaoemail" name="vlprovisaoemail" value=""
                <? echo $vlprovisaoemail ?>" />
						
              </td>
            </tr>

            <tr>
              <td>
                <label for="vlalteracaoprovemail">Valor altera&ccedil;&atilde;o de provis&atildeo envio de e-mail:</label>
                <input type="text" id="vlalteracaoprovemail" name="vlalteracaoprovemail" value=""
                <? echo $vlalteracaoprovemail ?>" />
						
              </td>
            </tr>

            <tr>
              <td>
                <label for="vlprovisaosaque">Valor provis&atilde;o de saque:</label>
                <input type="text" id="vlprovisaosaque" name="vlprovisaosaque" value=""
                <? echo $vlprovisaosaque ?>" />
						
              </td>
            </tr>

            <tr>
              <td>
                <label for="vlmonpagto">Valor monitora&ccedil;&atilde;o de pagamento:</label>
                <input type="text" id="vlmonpagto" name="vlmonpagto" value=""
                <? echo $vlmonpagto ?>" />
						
              </td>
            </tr>

            <tr>
              <td>
                <label for="vllimitepagtoespecie">Limite pagamento boleto em esp&eacute;cie:</label>
                <input type="text" id="vllimitepagtoespecie" name="vllimitepagtoespecie" value=""
                <? echo $vllimitepagtoespecie ?>" />
						
              </td>
            </tr>

            <tr>
              <td>
                <label for="qtdiasprovisao">Dias &uacute;teis para provis&atilde;o:</label>
                <input type="text" id="qtdiasprovisao"  class="txtPLDInt" name="qtdiasprovisao" value=""
                <? echo $qtdiasprovisao ?>" />
						
              </td>
            </tr>

            <tr>
              <td>
                <label for="hrlimiteprovisao">H&oacute;rario m&aacute;ximo para provis&atilde;o:</label>
                <input type="time" id="hrlimiteprovisao" name="hrlimiteprovisao" maxlength="5" value=""
                <? echo $hrlimiteprovisao ?>" />
						
              </td>
            </tr>

            <tr>
              <td>
                <label for="qtdiasprovisaocancelamento">Dias &uacute;teis para cancelamento de provis&atilde;o:</label>
                <input type="text" id="qtdiasprovisaocancelamento" class="txtPLDInt" name="qtdiasprovisaocancelamento" value=""
                <? echo $qtdiasprovisaocancelamento ?>" />
						
              </td>
            </tr>
          </table>
        </fieldset>
        <fieldset>
          <legend>Alertas</legend>
          <table width="100%">
            <tr>
              <td>
                <label for="inliberasaque" >Saque em esp&eacute;cie sem provis&atilde;o:</label>
                <input type="checkbox" id="inliberasaque" name="inliberasaque" value=""
                <? echo $inliberasaque ?>" />
						
              </td>
            </tr>
            <tr>
              <td>
                <label for="inliberaprovisaosaque" >Provisao de saque em esp&eacute;cie:</label>
                <input type="checkbox" id="inliberaprovisaosaque" name="inliberaprovisaosaque" value=""
                <? echo $inliberaprovisaosaque ?>" />
						
              </td>
            </tr>
            <tr>
              <td>
                <label for="inalteraprovisaopresencial" >Alteracao de provis&atilde;o n&atilde;o presencial:</label>
                <input type="checkbox" id="inalteraprovisaopresencial" name="inalteraprovisaopresencial" value=""
                <? echo $inalteraprovisaopresencial ?>" />
						
              </td>
            </tr>
            <tr>
              <td>
                <label for="inverificasaldo" >Verifica saldo:</label>
                <input type="checkbox" id="inverificasaldo" name="inverificasaldo" value=""
                <? echo $inverificasaldo ?>" />
						
              </td>
            </tr>
            <tr>
              <td>
                <label for="dsdemailseg" >E-mail seguran&ccedil;a corporativa:</label>
                <input type="email" id="dsdemailseg" class="txtEmail" name="dsdemailseg" value=""
                <? echo $dsdemailseg ?>" />
						
              </td>
            </tr>
            <tr>
              <td>
                <label for="dsdeemail" >E-mail sede cooperativa:</label>
                <input type="email" id="dsdeemail" class="txtEmail" name="dsdeemail" value=""
                <? echo $dsdeemail ?>" />							
						
              </td>
            </tr>
          </table>
        </fieldset>
      </div>
      <div id="divCoptel" style="display:none;">
        <label for="dsidpara">Selecione as Cooperativas:</label>
        <br />
        <select id="dsidpara" name="dsidpara[]" onchange="ver_rotina();" alt="Selecione a(s) Cooperativa(s).">
        </select>
        <span id="spanInfo">'Pressione CTRL para selecionar v&aacute;rias Cooperativas</span>
      </div>
    </fieldset>
  </form>
</div>