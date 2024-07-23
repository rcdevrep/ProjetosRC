#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"

/*/{Protheus.doc} XAGPIMES
Envio da Validação mensal Pirelli 
@author Leandro Spiller
@since 12/11/2021
@example u_XAGPIMES()
/*/
User Function XAGPIMES()

    Private cQuery     := ""
    Private cTexto     := ""
    Private cCabec     := ""
    Private cImprime   := ""
    Private lGerouDado := .F.
    Private cDATA      := ""
    Private cUltEnvio  :=  ""

    RpcSetType(3)
    RPCSetEnv("01","06")
	
    cUltEnvio  := alltrim( SuperGetMv("MV_XULTPI",.F.,"202111") ) 

    
    If !(isblind())
        cDATA := FWInputBox("Informe ANO MES no formato AAAAMM", "")
    else
        cDATA := substr(dtos( MonthSub( dDatabase, 1)),1,6 )
    Endif 

    //Caso já tenha rodado Ignora
    If cUltEnvio == cDATA
        If (isblind())
            Conout('XAGPIMES - Já enviado para o período '+cDATA)
            Return()
        Else 
            If !(MsgYesNo('Já foi enviado para esse período, deseja continuar? ', 'Já enviado!') )
                Return()
            Endif 
        Endif 
    Endif 

   
    Conout("XAGPIMES - cPeriodo: " + cDATA)
    
    cQuery    := " WITH VENDAS "
    cQuery    += " AS ("
    cQuery    += " SELECT" 
    cQuery    += "     SD2.D2_QUANT AS QUANT,"
    cQuery    += "     (SD2.D2_TOTAL + SD2.D2_VALIPI + SD2.D2_ICMSRET) AS VLTOTAL,"
    cQuery    += "     SD2.D2_EMISSAO,"
    cQuery    += "     CASE WHEN F4_DUPLIC = 'N' THEN 'BONIFICAÇÃO' ELSE 'VENDA' END AS TPTRANS"
    cQuery    += " FROM SD2010 SD2 WITH (NOLOCK)"
    cQuery    += " INNER JOIN SF2010 SF2 WITH (NOLOCK) ON SF2.F2_DOC = SD2.D2_DOC"
    cQuery    += "     AND SF2.F2_SERIE = SD2.D2_SERIE"
    cQuery    += "     AND SF2.F2_FILIAL = '06'"
    cQuery    += "     AND SF2.D_E_L_E_T_ = ''"
    cQuery    += " INNER JOIN SA1010 SA1 WITH (NOLOCK) ON SA1.A1_COD = SD2.D2_CLIENTE"
    cQuery    += "     AND SA1.A1_LOJA = SD2.D2_LOJA"
    cQuery    += "     AND SA1.A1_FILIAL = '  '"
    cQuery    += "     AND SA1.D_E_L_E_T_ = ''"
    cQuery    += " INNER JOIN SB1010 SB1 WITH (NOLOCK) ON SB1.B1_COD = SD2.D2_COD"
    cQuery    += "     AND SB1.B1_FILIAL = '06'"
    cQuery    += "     AND SB1.D_E_L_E_T_ = ''"
    cQuery    += "     AND SB1.B1_PROC = '014075'"
    cQuery    += "     AND SB1.B1_COD NOT IN ('PLLPB', 'PLLIPB')"
    cQuery    += " INNER JOIN SF4010 SF4 WITH (NOLOCK) ON SF4.F4_CODIGO = SD2.D2_TES"
    cQuery    += "     AND SF4.F4_FILIAL = '06'"
    cQuery    += "     AND SF4.D_E_L_E_T_ = ''"
    cQuery    += " INNER JOIN SA2010 SA2 WITH (NOLOCK) ON SB1.B1_PROC = SA2.A2_COD"
    cQuery    += "     AND SB1.B1_LOJPROC = SA2.A2_LOJA"
    cQuery    += "     AND SA2.A2_FILIAL = '  '"
    cQuery    += "     AND SA2.D_E_L_E_T_ = ''"
    cQuery    += " LEFT JOIN SA3010 SA3 WITH (NOLOCK) ON SA3.A3_COD = SF2.F2_VEND1"
    cQuery    += "     AND SA3.A3_FILIAL = '06'"
    cQuery    += "     AND SA3.D_E_L_E_T_ = ''"
    cQuery    += " WHERE substring(SD2.D2_EMISSAO,1,6) =  '"+cDATA+"' "// AND '"+cDATA_FIM+"' "
    cQuery    += "     AND SD2.D2_FILIAL = '06'"
    cQuery    += "     AND SD2.D_E_L_E_T_ = ''"
    cQuery    += "     AND SD2.D2_TIPO = 'N'"
	cQuery    += " "
    cQuery    += " UNION ALL"
	cQuery    += " "
    cQuery    += " SELECT" 
    cQuery    += "     SD1.D1_QUANT AS QUANT,"
    cQuery    += "     (SD1.D1_TOTAL + SD1.D1_VALIPI + SD1.D1_ICMSRET) AS VLTOTAL,"
    cQuery    += "     SD1.D1_DTDIGIT,"
    cQuery    += "     'DEVOLUÇÃO' AS TPTRANS"
    cQuery    += " FROM SD1010 SD1 WITH (NOLOCK)"
    cQuery    += " INNER JOIN SF1010 SF1 WITH (NOLOCK) ON SF1.F1_DOC = SD1.D1_DOC"
    cQuery    += "     AND SF1.F1_SERIE = SD1.D1_SERIE"
    cQuery    += "     AND SF1.F1_FORNECE = SD1.D1_FORNECE"
    cQuery    += "     AND SF1.F1_LOJA = SD1.D1_LOJA"
    cQuery    += "     AND SF1.F1_FILIAL = '06'"
    cQuery    += "     AND SF1.D_E_L_E_T_ = ''"
    cQuery    += "     AND SF1.F1_STATUS = 'A'"
    cQuery    += " INNER JOIN SA1010 SA1 WITH (NOLOCK) ON SA1.A1_COD = SD1.D1_FORNECE"
    cQuery    += "     AND SA1.A1_LOJA = SD1.D1_LOJA"
    cQuery    += "     AND SA1.A1_FILIAL = '  '"
    cQuery    += "     AND SA1.D_E_L_E_T_ = ''"
    cQuery    += " INNER JOIN SB1010 SB1 WITH (NOLOCK) ON SB1.B1_COD = SD1.D1_COD"
    cQuery    += "     AND SB1.B1_FILIAL = '06'"
    cQuery    += "     AND SB1.D_E_L_E_T_ = ''"
    cQuery    += "     AND SB1.B1_PROC = '014075'"
    cQuery    += "     AND SB1.B1_COD NOT IN ('PLLPB', 'PLLIPB')"
    cQuery    += " INNER JOIN SA2010 SA2 WITH (NOLOCK) ON SB1.B1_PROC = SA2.A2_COD"
    cQuery    += "     AND SB1.B1_LOJPROC = SA2.A2_LOJA"
    cQuery    += "     AND SA2.A2_FILIAL = '  '"
    cQuery    += "     AND SA2.D_E_L_E_T_ = ''"
    cQuery    += " WHERE substring(SD1.D1_DTDIGIT,1,6) = '"+cDATA+"' "//AND '"+cDATA_FIM+"' "
    cQuery    += "     AND SD1.D1_FILIAL = '06'"
    cQuery    += "     AND SD1.D_E_L_E_T_ = ''"
    cQuery    += "     AND SD1.D1_TIPO = 'D'"
    cQuery    += "     AND NOT EXISTS ("
    cQuery    += "         ("
    cQuery    += "             SELECT A5_CODPRF"
    cQuery    += "             FROM SA5010 SA5 WITH (NOLOCK)"
    cQuery    += "             WHERE SA5.A5_FORNECE = SA2.A2_COD"
    cQuery    += "                 AND SA5.A5_LOJA = SA2.A2_LOJA"
    cQuery    += "                 AND SA5.D_E_L_E_T_ = ''"
    cQuery    += "                 AND SA5.A5_PRODUTO = SB1.B1_COD"
    cQuery    += "                 AND A5_CODPRF = 'INATIVAR'"
    cQuery    += "                 AND SA5.A5_FILIAL = '06'"
    cQuery    += "             )"
    cQuery    += "         )"
    cQuery    += "     AND NOT EXISTS ("
    cQuery    += "         ("
    cQuery    += "             SELECT TOP 1 A5_CODPRF"
    cQuery    += "             FROM SA5010 SA5 WITH (NOLOCK)"
    cQuery    += "             WHERE SA5.A5_FORNECE = SA2.A2_COD"
    cQuery    += "                 AND SA5.D_E_L_E_T_ = ''"
    cQuery    += "                 AND SA5.A5_PRODUTO = SB1.B1_COD"
    cQuery    += "                 AND A5_CODPRF = 'INATIVAR'"
    cQuery    += "                 AND SA5.A5_FILIAL = '06'"
    cQuery    += "             )"
    cQuery    += "         )"
    cQuery    += " )"
    cQuery    += " SELECT "
    cQuery    += " SUM(QUANT) AS QUANT,"
    cQuery    += " SUM(VLTOTAL) AS VLTOTAL,"
    cQuery    += " YEAR(D2_EMISSAO) AS ANO,"
    cQuery    += " MONTH(D2_EMISSAO) AS MES,"
    cQuery    += " TPTRANS"
    cQuery    += " FROM VENDAS"
    cQuery    += " GROUP BY "
    cQuery    += " YEAR(D2_EMISSAO),"
    cQuery    += " MONTH(D2_EMISSAO),"
    cQuery    += " TPTRANS"
    cQuery    += " ORDER BY ANO, MES, TPTRANS"


    If Select("MPIRELLI") <> 0
		dbSelectArea("MPIRELLI")
		dbCloseArea()
	Endif
	
	TCQuery cQuery NEW ALIAS "MPIRELLI" 

    //cCabec := "| QUANT | VLTOTAL      | ANO  | MES | TPTRANS   |"+chr(13)
    cCabec := '<table border=2>'
    cCabec += " <tr>"
    cCabec += "   <td>QUANT</td> "
    cCabec += "   <td>VLTOTAL</td> "
    cCabec += "   <td>ANO</td> "
	cCabec += "   <td>MES</td> "
	cCabec += "   <td>TPTRANS</td>"
    cCabec += " </tr> "
    
    While MPIRELLI->(!eof())

        /*cTexto  += "| "+PADR(alltrim(str(MPIRELLI->QUANT)),5,'') + ' | ';
         +PADR(alltrim(str(MPIRELLI->VLTOTAL)),12,'') +' | ' ;
         +PADR(alltrim(str(MPIRELLI->ANO)),4,'') +' | '+;
          PADR(alltrim(MPIRELLI->MES),3,'') +' | '+ ;
          PADR(alltrim(MPIRELLI->TPTRANS),10,'')+"|"+chr(13)*/
        lGerouDado := .T.

        cTexto += " <tr>"
        cTexto += "   <td>"+PADR(alltrim(str(MPIRELLI->QUANT)),5,'') +"</td> "
        cTexto += "   <td>"+PADR(alltrim(STRTRAN(str(MPIRELLI->VLTOTAL),'.',',')),12,'') +"</td> "
        cTexto += "   <td>"+PADR(alltrim(str(MPIRELLI->ANO)),4,'')+"</td> "
        cTexto += "   <td>"+PADR(alltrim(str(MPIRELLI->MES)),3,'') +"</td> "
        cTexto += "   <td>"+PADR(alltrim(MPIRELLI->TPTRANS),11,'')+"</td>"
        cTexto += " </tr> "

        MPIRELLI->(dbskip())
    Enddo

    //cImprime := cLinha + cCabec + cTexto + cLinha
    cImprime := cCabec + cTexto + '</table>'
    
    CONOUT(cImprime)

    EnvMail( cDATA, cImprime )


    PutMv("MV_XULTPI",cDATA)
 
    
    RpcClearEnv()

  

Return


Static Function EnvMail( _cMes, _cMsg )


	_cFrom    := "timeprotheus@agricopel.com.br"//"protheus@agricopel.com.br"
    _cto      :=  alltrim( SuperGetMv("MV_XMAILPI",.F.,"leandro.h@agricopel.com.br") ) 
    _cSubject := "[DAD NEOGRID] Validação do período "+_cMes
    
    //Retira , e ' 
    _cto := STRTRAN(_cto, "'", "")
    _cto := alltrim( STRTRAN(_cto, ",", ";") )

    If alltrim(_cTo) == "" .OR. ( 'HOM' $ alltrim(GetEnvServer())  .OR.  'MIGRA' $ alltrim(GetEnvServer()) )  .OR. !lGerouDado
        _cTo  := 'leandro.h@agricopel.com.br'   
        _Cc   := ""
    Endif     

    lEnvioMail := SendMail(_cFrom, _cTo, '', _cSubject, _cMsg, '')
        
    //Se deu Algum erro no envio gravou  
    If !lEnvioMail 
        _cTo  := 'ERRO - '+alltrim(_cTo) 
    Endif 

Return


Static Function SendMail(cFrom, cTo, cCC, cSubject, cMsg, cAttach)
********************************************************************

	Local cServer    := GetMV("MV_RELSERV"),;
		  cAccount   := GetMV("MV_RELACNT"),;
		  cPassword  := GetMV("MV_RELPSW"),;
		  lAutentica := GetMv("MV_RELAUTH")
	Local lEmOk, cError    
	
	Begin Sequence 
	
	// conout('OpenSendMail')
	
	If !Empty(cServer) .and. !Empty(cAccount)
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lEmOk
		If lEmOk
			If lAutentica
				If !MailAuth(cAccount, cPassword)
					DISCONNECT SMTP SERVER
					MsgInfo("Falha na Autenticacao do Usuario","Alerta")
					lEmOk := .F.
					Break
				EndIf
			EndIf
				
			If cAttach <> Nil
				SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cMsg ATTACHMENT cAttach Result lEmOk
			Else
				SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cMsg Result lEmOk
			Endif
				
			If !lEmOk
				GET MAIL ERROR cError
				// Conout("Erro no envio de Email - "+cError+" O e-mail '"+cSubject+"' não pôde ser enviado.", "Alerta")
			Else
				//MsgInfo(STR0046, STR0056)//
				// Conout("E-mail enviado com sucesso - "+cTo)
			EndIf
			DISCONNECT SMTP SERVER
		Else
			GET MAIL ERROR cError
			DISCONNECT SMTP SERVER
			// Conout("Erro na conexão com o servidor de Email - "+cError+"O e-mail '"+cSubject+"' não pôde ser enviado.","Alerta")
		EndIf
	Else
		// Conout("Não foi possível enviar o e-mail porque o as informações de servidor e conta de envio não estão configuradas corretamente.", "Alerta")  
		lEmOk := .F.
	EndIf
	
	End Sequence

Return lEmOk
           

