<?php

/* ---------- Super Classe documento_pagamento ---------- */

class documento_pagamento {

    var $CodigoBarras = "";
    var $LinhaDigitavel = array();
    var $Valor = 0;
    var $Vencimento = "";
    var $Erro = "";

    function setVencimento($Vencimento) {
        $this->Vencimento = $Vencimento;
    }

    function setValor($Valor) {
        $this->Valor = $Valor;
    }

    function setCodigoBarras($CodigoBarras) {
        $this->CodigoBarras = $CodigoBarras;
    }

    function setLinhaDigitavel($LinhaDigitavel) {
        $this->LinhaDigitavel[0] = $LinhaDigitavel;
    }

    function setLinhaDigitavel1($LinhaDigitavel1) {
        $this->LinhaDigitavel[1] = $LinhaDigitavel1;
    }

    function setLinhaDigitavel2($LinhaDigitavel2) {
        $this->LinhaDigitavel[2] = $LinhaDigitavel2;
    }

    function setLinhaDigitavel3($LinhaDigitavel3) {
        $this->LinhaDigitavel[3] = $LinhaDigitavel3;
    }

    function setLinhaDigitavel4($LinhaDigitavel4) {
        $this->LinhaDigitavel[4] = $LinhaDigitavel4;
    }

    function setLinhaDigitavel5($LinhaDigitavel5) {
        $this->LinhaDigitavel[5] = $LinhaDigitavel5;
    }

    function setErro($Erro) {
        $this->Erro = $Erro;
    }

    function getVencimento() {
        return $this->Vencimento;
    }

    function getValor() {
        return $this->Valor;
    }

    function getCodigoBarras() {
        return $this->CodigoBarras;
    }

    function getLinhaDigitavel() {
        return $this->LinhaDigitavel[0];
    }

    function getLinhaDigitavel1() {
        return $this->LinhaDigitavel[1];
    }

    function getLinhaDigitavel2() {
        return $this->LinhaDigitavel[2];
    }

    function getLinhaDigitavel3() {
        return $this->LinhaDigitavel[3];
    }

    function getLinhaDigitavel4() {
        return $this->LinhaDigitavel[4];
    }

    function getLinhaDigitavel5() {
        return $this->LinhaDigitavel[5];
    }

    function getErro() {
        return $this->Erro;
    }

    function AcrescentaZeros($Valor, $QtdZeros) {
        $QtdZeros = $QtdZeros - strlen($Valor);

        for ($i = 0; $i < $QtdZeros; $i++) {
            $Valor = "0" . $Valor;
        }

        return $Valor;
    }

}

/* ---------- Super Classe documento_pagamento ---------- */

/* -------------- Sub-Classe valida_titulo -------------- */

class valida_titulo extends documento_pagamento {

    // Fun��o construtora da classe - Identifica se foi informada entrada de tipo "0" ou "1"
    function valida_titulo($TipoRepNumerica, $RepNumerica) {
        if ($TipoRepNumerica == "CB") {
            $this->MontaLinhaDigitavel($RepNumerica);
            $this->setCodigoBarras($RepNumerica);
        } elseif ($TipoRepNumerica == "LD") {
            $this->SeparaLinhaDigitavel($RepNumerica);
            $this->MontaCodigoBarras();
        }
    }

    // Monta Linha Digit�vel atrav�s do C�digo de Barras
    function MontaLinhaDigitavel($CodigoBarras) {
        $AuxLinhaDigitavel = substr($CodigoBarras, 0, 4) . substr($CodigoBarras, 19, 1) . substr($CodigoBarras, 20, 4);
        $this->setLinhaDigitavel1($AuxLinhaDigitavel . ($this->CalculaDVLinhaDigitavel($AuxLinhaDigitavel . "0")));

        $AuxLinhaDigitavel = substr($CodigoBarras, 24, 10);
        $this->setLinhaDigitavel2($AuxLinhaDigitavel . ($this->CalculaDVLinhaDigitavel($AuxLinhaDigitavel . "0")));

        $AuxLinhaDigitavel = substr($CodigoBarras, 34, 10);
        $this->setLinhaDigitavel3($AuxLinhaDigitavel . ($this->CalculaDVLinhaDigitavel($AuxLinhaDigitavel . "0")));

        $this->setLinhaDigitavel4(substr($CodigoBarras, 4, 1));

        $this->setLinhaDigitavel5(substr($CodigoBarras, 5, 14));

        $this->setLinhaDigitavel($this->getLinhaDigitavel1() . $this->getLinhaDigitavel2() . $this->getLinhaDigitavel3() .
                $this->getLinhaDigitavel4() . $this->AcrescentaZeros($this->getLinhaDigitavel5(), 14));
    }

    // Quebrar Linha Digitavel em 5 partes
    function SeparaLinhaDigitavel($LinhaDigitavel) {
        $this->setLinhaDigitavel($LinhaDigitavel);
        $this->setLinhaDigitavel1(substr($LinhaDigitavel, 0, 10));
        $this->setLinhaDigitavel2(substr($LinhaDigitavel, 10, 11));
        $this->setLinhaDigitavel3(substr($LinhaDigitavel, 21, 11));
        $this->setLinhaDigitavel4(substr($LinhaDigitavel, 32, 1));
        $this->setLinhaDigitavel5($this->AcrescentaZeros(substr($LinhaDigitavel, 33, 14), 14));
    }

    // Monta C�digo de Barras atrav�s da Linha Digit�vel
    function MontaCodigoBarras() {
        $this->setCodigoBarras(substr($this->getLinhaDigitavel1(), 0, 4) . $this->getLinhaDigitavel4() . $this->getLinhaDigitavel5() .
                substr($this->getLinhaDigitavel1(), 4, 1) . substr($this->getLinhaDigitavel1(), 5, 4) .
                substr($this->getLinhaDigitavel2(), 0, 10) . substr($this->getLinhaDigitavel3(), 0, 10));
    }

    // Executa verifica��o do C�digo de Barras e Linha Digitavel, e executa c�lculo dos Dados do Boleto
    function IniciaValidacao() {
        $Erro = "";

        if ($this->getLinhaDigitavel() == "" || $this->getCodigoBarras() == "") {
            $Erro .= "Dados incompletos\\n";
        }

        if (!$this->ValidaLinhaDigitavel($this->getLinhaDigitavel1(), true)) {
            $Erro .= "Parte 1 da linha digitavel invalida - " . $this->getLinhaDigitavel1() . "\\n";
        }

        if (!$this->ValidaLinhaDigitavel($this->getLinhaDigitavel2(), false)) {
            $Erro .= "Parte 2 da linha digitavel invalida - " . $this->getLinhaDigitavel2() . "\\n";
        }

        if (!$this->ValidaLinhaDigitavel($this->getLinhaDigitavel3(), false)) {
            $Erro .= "Parte 3 da linha digitavel invalida - " . $this->getLinhaDigitavel3() . "\\n";
        }

        $Erro .= $this->ValidaCodigoBarras();

        if ($Erro <> "") {
            $this->setErro($Erro);
            return false;
        }

        $this->CalculaDados();

        return true;
    }

    // Calcula Digito Verificador da Linha Digit�vel
    function ValidaLinhaDigitavel($LinhaDigitavel, $ValidaZeros = false) {
        $AuxLinhaDigitavel = doubleval($LinhaDigitavel);

        if ($ValidaZeros && strlen($AuxLinhaDigitavel) < 2) {
            return false;
        }

        if (substr($AuxLinhaDigitavel, (strlen($AuxLinhaDigitavel) - 1), 1) <> $this->CalculaDVLinhaDigitavel($AuxLinhaDigitavel)) {
            return false;
        }

        return true;
    }

    // Calcula Digito Verificador do C�digo de Barras
    function ValidaCodigoBarras() {
        $Erro = "";
        $CodigoBarras = $this->getCodigoBarras();
        $Peso = 2;
        $DesCalculo = $CodigoBarras;
        $CodigoBarras = substr($DesCalculo, 0, 4) . substr($DesCalculo, 5, 39);
        $DigCodigoBarras = substr($DesCalculo, 4, 1);
        $Calculo = 0;

        if ($DigCodigoBarras <> "0") {
            for ($i = (strlen($CodigoBarras) - 1); $i >= 0; $i--) {
                $Calculo += substr($CodigoBarras, $i, 1) * $Peso;
                $Peso++;

                if ($Peso > 9) {
                    $Peso = 2;
                }
            }

            $Resto = 11 - ($Calculo % 11);

            if ($Resto > 9 || $Resto == 0 || $Resto == 1) {
                $Digito = 1;
            } else {
                $Digito = $Resto;
            }

            if ($Digito <> $DigCodigoBarras) {
                $Erro = "DV do codigo de barras invalido / DV informado = " . $DigCodigoBarras . " - DV correto = " . $Digito . "\\n";
                return $Erro;
            }
        }

        return $Erro;
    }

    function CalculaDVLinhaDigitavel($LinhaDigitavel) {
        if (!is_double($LinhaDigitavel)) {
            $LinhaDigitavel = doubleval($LinhaDigitavel);
        }

        $Peso = 2;
        $Calculo = 0;

        for ($i = (strlen($LinhaDigitavel) - 2); $i >= 0; $i--) {
            $Resultado = substr($LinhaDigitavel, $i, 1) * $Peso;

            if ($Resultado > 9) {
                $Resultado = substr($Resultado, 0, 1) + substr($Resultado, 1, 1);
            }

            $Calculo += $Resultado;
            $Peso--;

            if ($Peso == 0) {
                $Peso = 2;
            }
        }

        if (strlen($Calculo) == 1) {
            $Calculo = "0" . $Calculo;
        }

        $Dezena = (substr($Calculo, 0, 1) + 1) * 10;
        $Digito = $Dezena - $Calculo;

        if ($Digito == 10) {
            $Digito = 0;
        }

        return $Digito;
    }

    // Calcula Dados do Boleto
    function CalculaDados() {
        $Vencimento = intval(substr($this->getLinhaDigitavel5(), 0, 4)) > 0 ? strftime("%d/%m/%Y", strtotime("19971007 + " . intval(substr($this->getLinhaDigitavel5(), 0, 4)) . " days")) : "";
        $Valor = doubleval(substr($this->getLinhaDigitavel5(), 4, 10)) / 100;

        $this->setVencimento($Vencimento);
        $this->setValor($Valor);
    }

}

/* -------------- Sub-Classe valida_titulo -------------- */

/* -------------- Sub-Classe valida_fatura -------------- */

class valida_fatura extends documento_pagamento {

    // Fun��o construtora da classe - Identifica se foi feita leitura atrav�s da Linha Digit�vel ou C�digo de Barras
    function valida_fatura($TipoRepNumerica, $RepNumerica) {
        if ($TipoRepNumerica == "CB") { // C�digo de Barras
            $this->MontaLinhaDigitavel($RepNumerica);
            $this->setCodigoBarras($RepNumerica);
        } elseif ($TipoRepNumerica == "LD") { // Linha Digit�vel
            $this->SeparaLinhaDigitavel($RepNumerica);
            $this->MontaCodigoBarras();
        }
    }

    // Monta Linha Digit�vel atrav�s do C�digo de Barras
    function MontaLinhaDigitavel($CodigoBarras) {
        $this->setLinhaDigitavel1(substr($CodigoBarras, 0, 11) . $this->CalculaDV(substr($CodigoBarras, 0, 11)));
        $this->setLinhaDigitavel2(substr($CodigoBarras, 11, 11) . $this->CalculaDV(substr($CodigoBarras, 11, 11)));
        $this->setLinhaDigitavel3(substr($CodigoBarras, 22, 11) . $this->CalculaDV(substr($CodigoBarras, 22, 11)));
        $this->setLinhaDigitavel4(substr($CodigoBarras, 33, 11) . $this->CalculaDV(substr($CodigoBarras, 33, 11)));
        $this->setLinhaDigitavel($this->getLinhaDigitavel1() . $this->getLinhaDigitavel2() .
                $this->getLinhaDigitavel3() . $this->getLinhaDigitavel4());
    }

    // Quebrar Linha Digitavel em 4 partes
    function SeparaLinhaDigitavel($LinhaDigitavel) {
        $this->setLinhaDigitavel($LinhaDigitavel);
        $this->setLinhaDigitavel1(substr($LinhaDigitavel, 0, 12));
        $this->setLinhaDigitavel2(substr($LinhaDigitavel, 12, 12));
        $this->setLinhaDigitavel3(substr($LinhaDigitavel, 24, 12));
        $this->setLinhaDigitavel4(substr($LinhaDigitavel, 36, 12));
    }

    // Monta C�digo de Barras atrav�s da Linha Digit�vel
    function MontaCodigoBarras() {
        $this->setCodigoBarras(substr($this->getLinhaDigitavel1(), 0, 11) . substr($this->getLinhaDigitavel2(), 0, 11) .
                substr($this->getLinhaDigitavel3(), 0, 11) . substr($this->getLinhaDigitavel4(), 0, 11));
    }

    // Executa verifica��o do C�digo de Barras e Linha Digitavel, e executa c�lculo dos Dados da Fatura
    function IniciaValidacao() {
        $Erro = "";

        if ($this->getLinhaDigitavel() == "" || $this->getCodigoBarras() == "") {
            $Erro .= "Dados incompletos\\n";
        }

        $Erro .= $this->ValidaDVLinhaDigitavel($this->getLinhaDigitavel1(), "1");
        $Erro .= $this->ValidaDVLinhaDigitavel($this->getLinhaDigitavel2(), "2");
        $Erro .= $this->ValidaDVLinhaDigitavel($this->getLinhaDigitavel3(), "3");
        $Erro .= $this->ValidaDVLinhaDigitavel($this->getLinhaDigitavel4(), "4");

        $Erro .= $this->validaDVCodigoBarras($this->getCodigoBarras());

        if ($Erro <> "") {
            $this->setErro($Erro);
            return false;
        }

        $this->CalculaDados();

        return true;
    }

    // Fun��o para validar digito verificador do c�digo de barras
    function validaDVCodigoBarras($DesCalculo) {
        $DigVerificador = substr($DesCalculo, 3, 1);
        $Digito = $this->CalculaDV($DesCalculo);

        if ($Digito <> $DigVerificador) {
            if (substr($DesCalculo, 15, 4) == "0163") { // Fatura Claro - Calcular atrav�s do m�dulo 11
                $Digito = $this->CalculaDVModulo11($DesCalculo);

                if ($Digito <> $DigVerificador) {
                    return "DV do Codigo de barras invalido / DV informado = " . $DigVerificador . " - DV correto = " . $Digito . "\\n";
                }
            } else {
                return "DV do Codigo de barras invalido / DV informado = " . $DigVerificador . " - DV correto = " . $Digito . "\\n";
            }
        }

        return "";
    }

    // Fun��o para validar digitos verificadores da linha digit�vel
    function ValidaDVLinhaDigitavel($DesCalculo, $IndLinhaDigitavel) {
        $DigVerificador = substr($DesCalculo, 11, 1);
        $Digito = $this->CalculaDV(substr($DesCalculo, 0, 11));

        if ($Digito <> $DigVerificador) {
            if (substr($this->getCodigoBarras(), 15, 4) == "0163") { // Fatura Claro - Calcular atrav�s do m�dulo 11
                $Digito = $this->CalculaDVModulo11(substr($DesCalculo, 0, 11));

                if ($Digito <> $DigVerificador) {
                    return "DV da Parte " . $IndLinhaDigitavel . " da linha digitavel invalido / DV informado = " . $DigVerificador . " - DV correto = " . $Digito . "\\n";
                }
            } else {
                return "DV da Parte " . $IndLinhaDigitavel . " da linha digitavel invalido / DV informado = " . $DigVerificador . " - DV correto = " . $Digito . "\\n";
            }
        }

        return "";
    }

    // Calcula Digito Verificador do C�digo de Barras ou de "parte" da Linha Digit�vel
    function CalculaDV($DesCalculo) {
        $CodigoBarras = $this->AcrescentaZeros($DesCalculo, 44);
        $DesCalculo = substr($CodigoBarras, 0, 3) . substr($CodigoBarras, 4, 40);
        $Peso = 2;
        $Calculo = 0;

        for ($i = 0; $i < strlen($DesCalculo); $i++) {
            $Resultado = substr($DesCalculo, $i, 1) * $Peso;

            if (strlen($Resultado) == 2) {
                $Calculo += substr($Resultado, 0, 1) + substr($Resultado, 1, 1);
            } else {
                $Calculo += $Resultado;
            }

            if ($Peso == 2) {
                $Peso = 1;
            } else {
                $Peso = 2;
            }
        }

        $Resto = 10 - ($Calculo % 10);

        if ($Resto == 10) {
            $Digito = 0;
        } else {
            $Digito = $Resto;
        }

        return $Digito;
    }

    // Calcula Digito Verificador do C�digo de Barras atrav�s do m�dulo 11
    function CalculaDVModulo11($DesCalculo) {
        $CodigoBarras = $this->AcrescentaZeros($DesCalculo, 44);
        $DesCalculo = substr($CodigoBarras, 0, 3) . substr($CodigoBarras, 4, 40);
        $Peso = 2;
        $Calculo = 0;

        for ($i = (strlen($DesCalculo) - 1); $i >= 0; $i--) {
            $Calculo += substr($DesCalculo, $i, 1) * $Peso;
            $Peso++;

            if ($Peso > 9) {
                $Peso = 2;
            }
        }

        $Resto = $Calculo % 11;

        if ($Resto == 0 || $Resto == 1) {
            $Digito = 0;
        } elseif ($Resto == 10) {
            $Digito = 1;
        } else {
            $Digito = 11 - $Resto;
        }

        return $Digito;
    }

    // Calcula Dados da Fatura
    function CalculaDados() {
        $Valor = doubleval(substr($this->getCodigoBarras(), 4, 11)) / 100;

        $this->setValor($Valor);
    }

}

/* -------------- Sub-Classe valida_fatura -------------- */
?>