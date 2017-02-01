<?php
/*
 * FONTE        : form_emprestimo.php
 * CRIAÇÃO      : Renato Darosci (Supero)
 * DATA CRIAÇÃO : 07/06/2016
 * OBJETIVO     : Formulário de associado para a tela IMOVEL
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

?>

<fieldset id="FS_IMOVEL">
	<legend> Imóvel </legend>

	<label for="idseqbem">Imóvel:</label>
	<select id="idseqbem" name="idseqbem"></select>
	<a href="#" class="botao" id="btnOk2">Ok</a>
	
	<br style="clear:both" /><br />

	<!-- LINHA 1 -->
	<label for="nrmatcar">Matrícula:</label>
	<input type="text" id="nrmatcar" name="nrmatcar" maxlength="10" />
	<label for="nrcnscar">CNS Cartório:</label>
	<input type="text" id="nrcnscar" name="nrcnscar" maxlength="6" />
	<label for="tpimovel">Tipo Imóvel:</label>
	<select id="tpimovel" name="tpimovel" >
        <option value="1" <?php echo getByTagName($dados,'tpimovel') == '1' ? 'selected' : '' ?>>1 - Casa</option>
        <option value="2" <?php echo getByTagName($dados,'tpimovel') == '2' ? 'selected' : '' ?>>2 - Apartamento</option>
    </select>
	<!-- LINHA 2 -->
	<label for="nrreggar">Número Registro:</label>
	<input type="text" id="nrreggar" name="nrreggar" maxlength="15" />
	<label for="dtreggar">Data Registro:</label>
	<input type="text" id="dtreggar" name="dtreggar" value="<?php echo getByTagName($dados,'dtreggar') ?>" />
	<label for="nrgragar">Grau Garantia:</label>
	<select id="nrgragar" name="nrgragar">
        <option value="0" <?php echo getByTagName($dados,'nrgragar') == '0' ? 'selected' : '' ?>>0 - Alienação fiduciária</option>
        <option value="1" <?php echo getByTagName($dados,'nrgragar') == '1' ? 'selected' : '' ?>>1 - Hipoteca - primeiro grau</option>
        <option value="2" <?php echo getByTagName($dados,'nrgragar') == '2' ? 'selected' : '' ?>>2 - Hipoteca - segundo grau</option>
        <option value="3" <?php echo getByTagName($dados,'nrgragar') == '3' ? 'selected' : '' ?>>3 - Hipoteca - outros graus</option>
    </select>
	<!-- LINHA 3 -->
	<label for="nrceplgr">CEP:</label>
	<input type="text" name="nrceplgr" id="nrceplgr" maxlength="9" >
	<a  class="lupa" style="cursor: auto;"><img src="http://t0030502.ayllosdev.cecred.coop.br/imagens/geral/ico_lupa.gif"></a>
	<!-- LINHA 4 -->
	<label for="tplograd">Tipo Logradouro:</label>
	<select id="tplograd" name="tplograd">
        <option value=""   <?php echo getByTagName($dados,'tplograd') == ''   ? 'selected' : '' ?>></option>
        <option value="1"  <?php echo getByTagName($dados,'tplograd') == '1'  ? 'selected' : '' ?>>Aeroporto</option>
        <option value="2"  <?php echo getByTagName($dados,'tplograd') == '2'  ? 'selected' : '' ?>>Alameda</option>
        <option value="3"  <?php echo getByTagName($dados,'tplograd') == '3'  ? 'selected' : '' ?>>Área</option>
        <option value="4"  <?php echo getByTagName($dados,'tplograd') == '4'  ? 'selected' : '' ?>>Avenida</option>
        <option value="5"  <?php echo getByTagName($dados,'tplograd') == '5'  ? 'selected' : '' ?>>Campo</option>
        <option value="6"  <?php echo getByTagName($dados,'tplograd') == '6'  ? 'selected' : '' ?>>Chácara</option>
        <option value="7"  <?php echo getByTagName($dados,'tplograd') == '7'  ? 'selected' : '' ?>>Colônia</option>
        <option value="8"  <?php echo getByTagName($dados,'tplograd') == '8'  ? 'selected' : '' ?>>Condomínio</option>
        <option value="9"  <?php echo getByTagName($dados,'tplograd') == '9'  ? 'selected' : '' ?>>Conjunto</option>
        <option value="10" <?php echo getByTagName($dados,'tplograd') == '10' ? 'selected' : '' ?>>Distrito</option>
        <option value="11" <?php echo getByTagName($dados,'tplograd') == '11' ? 'selected' : '' ?>>Esplanada</option>
        <option value="12" <?php echo getByTagName($dados,'tplograd') == '12' ? 'selected' : '' ?>>Estação</option>
        <option value="13" <?php echo getByTagName($dados,'tplograd') == '13' ? 'selected' : '' ?>>Estrada</option>
        <option value="14" <?php echo getByTagName($dados,'tplograd') == '14' ? 'selected' : '' ?>>Favela</option>
        <option value="15" <?php echo getByTagName($dados,'tplograd') == '15' ? 'selected' : '' ?>>Fazenda</option>
        <option value="16" <?php echo getByTagName($dados,'tplograd') == '16' ? 'selected' : '' ?>>Feira</option>
        <option value="17" <?php echo getByTagName($dados,'tplograd') == '17' ? 'selected' : '' ?>>Jardim</option>
        <option value="18" <?php echo getByTagName($dados,'tplograd') == '18' ? 'selected' : '' ?>>Ladeira</option>
        <option value="19" <?php echo getByTagName($dados,'tplograd') == '19' ? 'selected' : '' ?>>Lago</option>
        <option value="20" <?php echo getByTagName($dados,'tplograd') == '20' ? 'selected' : '' ?>>Lagoa</option>
        <option value="21" <?php echo getByTagName($dados,'tplograd') == '21' ? 'selected' : '' ?>>Largo</option>
        <option value="22" <?php echo getByTagName($dados,'tplograd') == '22' ? 'selected' : '' ?>>Loteamento</option>
        <option value="23" <?php echo getByTagName($dados,'tplograd') == '23' ? 'selected' : '' ?>>Morro</option>
        <option value="24" <?php echo getByTagName($dados,'tplograd') == '24' ? 'selected' : '' ?>>Núcleo</option>
        <option value="25" <?php echo getByTagName($dados,'tplograd') == '25' ? 'selected' : '' ?>>Parque</option>
        <option value="26" <?php echo getByTagName($dados,'tplograd') == '26' ? 'selected' : '' ?>>Passarela</option>
        <option value="27" <?php echo getByTagName($dados,'tplograd') == '27' ? 'selected' : '' ?>>Pátio</option>
        <option value="28" <?php echo getByTagName($dados,'tplograd') == '28' ? 'selected' : '' ?>>Praça</option>
        <option value="29" <?php echo getByTagName($dados,'tplograd') == '29' ? 'selected' : '' ?>>Quadra</option>
        <option value="30" <?php echo getByTagName($dados,'tplograd') == '30' ? 'selected' : '' ?>>Recanto</option>
        <option value="31" <?php echo getByTagName($dados,'tplograd') == '31' ? 'selected' : '' ?>>Residencial</option>
        <option value="32" <?php echo getByTagName($dados,'tplograd') == '32' ? 'selected' : '' ?>>Rodovia</option>
        <option value="33" <?php echo getByTagName($dados,'tplograd') == '33' ? 'selected' : '' ?>>Rua</option>
        <option value="34" <?php echo getByTagName($dados,'tplograd') == '34' ? 'selected' : '' ?>>Setor</option>
        <option value="35" <?php echo getByTagName($dados,'tplograd') == '35' ? 'selected' : '' ?>>Sítio</option>
        <option value="36" <?php echo getByTagName($dados,'tplograd') == '36' ? 'selected' : '' ?>>Travessa</option>
        <option value="37" <?php echo getByTagName($dados,'tplograd') == '37' ? 'selected' : '' ?>>Trecho</option>
        <option value="38" <?php echo getByTagName($dados,'tplograd') == '38' ? 'selected' : '' ?>>Trevo</option>
        <option value="39" <?php echo getByTagName($dados,'tplograd') == '39' ? 'selected' : '' ?>>Vale</option>
        <option value="40" <?php echo getByTagName($dados,'tplograd') == '40' ? 'selected' : '' ?>>Vereda</option>
        <option value="41" <?php echo getByTagName($dados,'tplograd') == '41' ? 'selected' : '' ?>>Via</option>
        <option value="42" <?php echo getByTagName($dados,'tplograd') == '42' ? 'selected' : '' ?>>Viaduto</option>
        <option value="43" <?php echo getByTagName($dados,'tplograd') == '43' ? 'selected' : '' ?>>Viela</option>
        <option value="44" <?php echo getByTagName($dados,'tplograd') == '44' ? 'selected' : '' ?>>Vila</option>
        <option value="99" <?php echo getByTagName($dados,'tplograd') == '99' ? 'selected' : '' ?>>Outros</option>
    </select>
	<label for="dslograd">Logradouro:</label>
	<input type="text" name="dslograd" id="dslograd" maxlength="60">
	<label for="nrlograd">Nr:</label>
	<input type="text" name="nrlograd" id="nrlograd" maxlength="7">
	<!-- LINHA 5 -->
	<label for="dscmplgr">Complemento:</label>
	<input type="text" name="dscmplgr" id="dscmplgr" maxlength="30">
	<label for="dsbairro">Bairro:</label>
	<input type="text" name="dsbairro" id="dsbairro" maxlength="20">
	<!-- LINHA 6 -->
	<label for="cdestado">UF:</label>
	<select id="cdestado" name="cdestado">
        <option value=""   <?php echo getByTagName($dados,'dsduflgr') == ''   ? 'selected' : '' ?>></option>
        <option value="AC" <?php echo getByTagName($dados,'dsduflgr') == 'AC' ? 'selected' : '' ?>>AC</option>
        <option value="AL" <?php echo getByTagName($dados,'dsduflgr') == 'AL' ? 'selected' : '' ?>>AL</option>
        <option value="AM" <?php echo getByTagName($dados,'dsduflgr') == 'AM' ? 'selected' : '' ?>>AM</option>
        <option value="AP" <?php echo getByTagName($dados,'dsduflgr') == 'AP' ? 'selected' : '' ?>>AP</option>
        <option value="BA" <?php echo getByTagName($dados,'dsduflgr') == 'BA' ? 'selected' : '' ?>>BA</option>
        <option value="CE" <?php echo getByTagName($dados,'dsduflgr') == 'CE' ? 'selected' : '' ?>>CE</option>
        <option value="DF" <?php echo getByTagName($dados,'dsduflgr') == 'DF' ? 'selected' : '' ?>>DF</option>
        <option value="ES" <?php echo getByTagName($dados,'dsduflgr') == 'ES' ? 'selected' : '' ?>>ES</option>
        <option value="EX" <?php echo getByTagName($dados,'dsduflgr') == 'EX' ? 'selected' : '' ?>>EX</option>
        <option value="GO" <?php echo getByTagName($dados,'dsduflgr') == 'GO' ? 'selected' : '' ?>>GO</option>
        <option value="MA" <?php echo getByTagName($dados,'dsduflgr') == 'MA' ? 'selected' : '' ?>>MA</option>
        <option value="MG" <?php echo getByTagName($dados,'dsduflgr') == 'MG' ? 'selected' : '' ?>>MG</option>
        <option value="MS" <?php echo getByTagName($dados,'dsduflgr') == 'MS' ? 'selected' : '' ?>>MS</option>
        <option value="MT" <?php echo getByTagName($dados,'dsduflgr') == 'MT' ? 'selected' : '' ?>>MT</option>
        <option value="PA" <?php echo getByTagName($dados,'dsduflgr') == 'PA' ? 'selected' : '' ?>>PA</option>
        <option value="PB" <?php echo getByTagName($dados,'dsduflgr') == 'PB' ? 'selected' : '' ?>>PB</option>
        <option value="PE" <?php echo getByTagName($dados,'dsduflgr') == 'PE' ? 'selected' : '' ?>>PE</option>
        <option value="PI" <?php echo getByTagName($dados,'dsduflgr') == 'PI' ? 'selected' : '' ?>>PI</option>
        <option value="PR" <?php echo getByTagName($dados,'dsduflgr') == 'PR' ? 'selected' : '' ?>>PR</option>
        <option value="RJ" <?php echo getByTagName($dados,'dsduflgr') == 'RJ' ? 'selected' : '' ?>>RJ</option>
        <option value="RN" <?php echo getByTagName($dados,'dsduflgr') == 'RN' ? 'selected' : '' ?>>RN</option>
        <option value="RO" <?php echo getByTagName($dados,'dsduflgr') == 'RO' ? 'selected' : '' ?>>RO</option>
        <option value="RR" <?php echo getByTagName($dados,'dsduflgr') == 'RR' ? 'selected' : '' ?>>RR</option>
        <option value="RS" <?php echo getByTagName($dados,'dsduflgr') == 'RS' ? 'selected' : '' ?>>RS</option>
        <option value="SC" <?php echo getByTagName($dados,'dsduflgr') == 'SC' ? 'selected' : '' ?>>SC</option>
        <option value="SE" <?php echo getByTagName($dados,'dsduflgr') == 'SE' ? 'selected' : '' ?>>SE</option>
        <option value="SP" <?php echo getByTagName($dados,'dsduflgr') == 'SP' ? 'selected' : '' ?>>SP</option>
        <option value="TO" <?php echo getByTagName($dados,'dsduflgr') == 'TO' ? 'selected' : '' ?>>TO</option>
    </select>
	<label for="cdcidade">Cidade:</label>
	<select id="cdcidade" name="cdcidade">
        <option value="" selected >Selecione a UF...</option>
    </select>
	<input type="hidden" id="dscidade" name="dscidade">
	<!-- LINHA 7 -->
	<label for="dtavlimv">Data Avaliação:</label>
	<input type="text" name="dtavlimv" id="dtavlimv" >
	<label for="vlavlimv">Valor Avaliação:</label>
	<input type="text" name="vlavlimv" id="vlavlimv" >
	<label for="dtcprimv">Data Compra:</label>
	<input type="text" name="dtcprimv" id="dtcprimv" >
	<label for="vlcprimv">Valor Compra:</label>
	<input type="text" name="vlcprimv" id="vlcprimv" >
	<!-- LINHA 8 -->
	<label for="tpimpimv">Tipo Implantação:</label>
	<select id="tpimpimv" name="tpimpimv">
        <option value="1" <?php echo getByTagName($dados,'tpimpimv') == '1' ? 'selected' : '' ?>>1 - Condomínio</option>
        <option value="2" <?php echo getByTagName($dados,'tpimpimv') == '2' ? 'selected' : '' ?>>2 - Isolado</option>
    </select>
	<label for="incsvimv">Estado Conservação:</label>
	<select id="incsvimv" name="incsvimv">
        <option value="1" <?php echo getByTagName($dados,'incsvimb') == '1' ? 'selected' : '' ?>>1 - Bom</option>
        <option value="2" <?php echo getByTagName($dados,'incsvimb') == '2' ? 'selected' : '' ?>>2 - Regular</option>
        <option value="3" <?php echo getByTagName($dados,'incsvimb') == '3' ? 'selected' : '' ?>>3 - Ruim</option>
        <option value="4" <?php echo getByTagName($dados,'incsvimb') == '4' ? 'selected' : '' ?>>4 - Em construção</option>
    </select>
	<label for="inpdracb">Padrão Acabamento:</label>
	<select id="inpdracb" name="inpdracb">
        <option value="1" <?php echo getByTagName($dados,'inpdracb') == '1' ? 'selected' : '' ?>>1 - Alto</option>
        <option value="2" <?php echo getByTagName($dados,'inpdracb') == '2' ? 'selected' : '' ?>>2 - Normal</option>
        <option value="3" <?php echo getByTagName($dados,'inpdracb') == '3' ? 'selected' : '' ?>>3 - Baixo</option>
        <option value="4" <?php echo getByTagName($dados,'inpdracb') == '4' ? 'selected' : '' ?>>4 - Mínimo</option>
    </select>
	<!-- LINHA 9 -->
	<label for="vlmtrtot">Área Total:</label>
	<input type="text" name="vlmtrtot" id="vlmtrtot" >
	<label for="vlmtrpri">Área Privativa:</label>
	<input type="text" name="vlmtrpri" id="vlmtrpri" >
	<label for="qtdormit">Dormitórios:</label>
	<input type="text" name="qtdormit" id="qtdormit" maxlength="2">
	<label for="qtdvagas">Vagas Garagem:</label>
	<input type="text" name="qtdvagas" id="qtdvagas" maxlength="2">
	<!-- LINHA 10 -->
	<label for="vlmtrter">Área Terreno:</label>
	<input type="text" name="vlmtrter" id="vlmtrter" >
	<label for="vlmtrtes">Testada:</label>
	<input type="text" name="vlmtrtes" id="vlmtrtes" >
	<label for="incsvcon">Conservação Condomínio:</label>
	<select id="incsvcon" name="incsvcon">
        <option value="1" <?php echo getByTagName($dados,'incsvcon') == '1' ? 'selected' : '' ?>>1 - Bom</option>
        <option value="2" <?php echo getByTagName($dados,'incsvcon') == '2' ? 'selected' : '' ?>>2 - Regular</option>
        <option value="3" <?php echo getByTagName($dados,'incsvcon') == '3' ? 'selected' : '' ?>>3 - Ruim</option>
        <option value="4" <?php echo getByTagName($dados,'incsvcon') == '4' ? 'selected' : '' ?>>4 - Em implantação</option>
    </select>
	
</fieldset>
<fieldset id="FS_VENDEDOR">
	<legend> Vendedor </legend>
	<label for="inpesvdr">Natureza:</label>
	<select id="inpesvdr" name="inpesvdr">
        <option value=""  <?php echo getByTagName($dados,'inpesvdr') == ''  ? 'selected' : '' ?>></option>
        <option value="1" <?php echo getByTagName($dados,'inpesvdr') == '1' ? 'selected' : '' ?>>1 - Pessoa Física - CPF</option>
        <option value="2" <?php echo getByTagName($dados,'inpesvdr') == '2' ? 'selected' : '' ?>>2 - Pessoa Jurídica - CNPJ</option>
        <option value="3" <?php echo getByTagName($dados,'inpesvdr') == '3' ? 'selected' : '' ?>>3 - Pessoa Física no exterior</option>
        <option value="4" <?php echo getByTagName($dados,'inpesvdr') == '4' ? 'selected' : '' ?>>4 - Pessoa Jurídica no exterior</option>
        <option value="5" <?php echo getByTagName($dados,'inpesvdr') == '5' ? 'selected' : '' ?>>5 - Pessoa Física sem CPF</option>
        <option value="6" <?php echo getByTagName($dados,'inpesvdr') == '6' ? 'selected' : '' ?>>6 - Pessoa Jurídica sem CNPJ</option>
    </select>
	<label for="nrdocvdr">CNPJ/CPF:</label>
	<input type="text" name="nrdocvdr" id="nrdocvdr" maxlength="18">
	<label for="nmvendor">Nome/Razão:</label>
	<input type="text" name="nmvendor" id="nmvendor" maxlength="30">	
</fieldset>