<html>
        <head>
                <title>CNPJ e Captcha</title>
        </head>
        <body>
        <form method="post" action="processa.php">
                <p><span class="titleCats">CNPJ e Captcha</span>
                  <br />
                  <input type="text" name="nrcpfcgc" maxlength="19" value="" required /> 
                  <b style="color: red">CNPJ</b>
                  <br />
                  <img src="getcaptcha.php" border="0">
                  <br />
                  <input type="text" name="dscaptch" maxlength="6" required />
                  <b style="color: red">O que vê na imagem acima?</b>
                  <br />
                </p>
                <p>
                  <input id="id_submit" name="enviar" type="submit" value="Consultar"/>
                </p>
        </form>
        </body>
</html>