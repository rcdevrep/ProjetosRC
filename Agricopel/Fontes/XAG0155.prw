#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} XAG0155 
Rotina para Eliminação de residuos
@author RC
@since 08/05/2024
@version P12
@type function
/*/

User Function XAG0155S(aParam)

	DEFAULT aParam := {}

	PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2]

		U_XAG0155()

	RESET ENVIRONMENT

RETURN

User Function XAG0155()
	Local cQuery	 := ""
	Local cAlias     := "SC5"
	Local nReg       := 0
	Local nOpc       := 1
	Local lAutomato  := .T.
	Local cPedido    := ""
	Local nDias		 := 0
	Local nTotal	 := 0
	Local aArea      := GetArea()
	Local oFWMsExcel
	Local oExcel
	Local cArquivo   := GetTempPath()+'Limpeza de Resíduos - Pedidos.xml'
	Local aPergs     := {}
	Local aRetParm   := {}
	Local dEntregDe  := date()
	Local dEntregAte := date()
    Local _aPedidos  := {}
    Local _i         := 0 
	
	nDias	:= SuperGetMv("MV_XDRESID",,30)

	IF !IsBlind()
		aAdd(aPergs, {1, "Dt. Entrega de",  date()-365,  "", ".T.", "", ".T.", 80,  .F.})// MV_PAR01
    	aAdd(aPergs, {1, "Dt. Entrega Até", date()-nDias,  "", ".T.", "", ".T.", 80,  .F.})// MV_PAR02

		If ParamBox(aPergs,"Parâmetros",@aRetParm,{||.T.},,,,,,"",.T.,.T.)
		    dEntregDe    := aRetParm[1]
	        dEntregAte   := aRetParm[2]

			If !FWAlertNoYes("Confirma a limpeza de pedidos com dt.Entrega de "+dtoc(dEntregDe)+" ate "+dtoc(dEntregAte)+"?", "Limpeza de Resíduos")
				MsgInfo( 'Cancelado!', 'Limpeza de Resíduos' )
				Return 
			Endif 
		Else 
			Return
		Endif 
	Else
		dEntregDe    := stod('20230101')
	    dEntregAte   := DATE()-nDias
	Endif


	cQuery := "SELECT C5_FILIAL,C5_NUM,C5_EMISSAO,C5_CLIENTE, SC5.R_E_C_N_O_ RECNO FROM "+RetSqlName("SC5")+" SC5 "	+ CRLF
	cQuery += "INNER JOIN " +RetSqlName("SC6") + " SC6 " + "ON C6_FILIAL = C5_FILIAL AND C6_CLI = C5_CLIENTE AND C6_NUM = C5_NUM AND SC5.D_E_L_E_T_ <> '*' "	+ CRLF
	cQuery += "WHERE C6_FILIAL = '"+cFilAnt+"' AND C6_QTDVEN > C6_QTDENT AND C5_EMISSAO BETWEEN '"+dtos(dEntregDe)+"' AND '"+ DTOS(dEntregAte) +"' AND C6_BLQ IN(' ','N') "	+ CRLF
	cQuery += " AND C6_NOTA <> ' ' "
	cQuery += " AND SC6.D_E_L_E_T_ <> '*' AND C6_LOCAL <> '20' AND  C5_VEICULO = ' ' " + CRLF
	cQuery += " AND IIF(C5_FECENT > C6_ENTREG, C5_FECENT, C6_ENTREG) BETWEEN '"+dtos(dEntregDe)+"' AND '"+ DTOS(DATE()-nDias)+"' " + CRLF
	cQuery += "GROUP BY C5_FILIAL,C5_NUM,C5_EMISSAO,C5_CLIENTE, SC5.R_E_C_N_O_ "

	If Select("XAG0155") <> 0
		dbSelectArea("XAG0155")
   		dbCloseArea()
	Endif    
	
	TCQUERY cQuery NEW ALIAS "XAG0155"
	DbSelectArea("XAG0155")
	XAG0155->(DbGoTop())
	While XAG0155->(!Eof())

		cFilAnt := XAG0155->C5_FILIAL
		cPedido := XAG0155->C5_NUM
		nReg 	:= XAG0155->RECNO

		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		IF SC5->(MsSeek( cFilAnt + cPedido ))
				
            Ma410Resid(cAlias,nReg,nOpc,lAutomato)
			    
            nTotal++
            AADD(_aPedidos, {XAG0155->C5_FILIAL,;
					XAG0155->C5_NUM,;
					XAG0155->C5_CLIENTE,;
					dtoc(STOD(XAG0155->C5_EMISSAO))})
		ENDIF
		XAG0155->(dbSkip())
	Enddo

	IF !IsBlind()
		FWAlertInfo("Registros Processados: " + cValToChar(nTotal) , "Limpeza Concluída!")

		IF FWAlertNoYes("Deseja gerar relatório com pedidos processados?", "Limpeza de Resíduos")

			oFWMsExcel := FWMSExcel():New()

			oFWMsExcel:AddworkSheet("Pedidos")
			//Criando a Tabela
			oFWMsExcel:AddTable("Pedidos","Lista de Pedidos")
			oFWMsExcel:AddColumn("Pedidos","Lista de Pedidos","Filial",1,1)
			oFWMsExcel:AddColumn("Pedidos","Lista de Pedidos","Numero",1,1)
			oFWMsExcel:AddColumn("Pedidos","Lista de Pedidos","Cliente",1,1)
			oFWMsExcel:AddColumn("Pedidos","Lista de Pedidos","Emissão",1,1)
			//Criando as Linhas... Enquanto não for fim da query
			
            For _i := 1 to len(_aPedidos)
                oFWMsExcel:AddRow("Pedidos","Lista de Pedidos",{;
					_aPedidos[_i,1],;
					_aPedidos[_i,2],;
					_aPedidos[_i,3],;
					(_aPedidos[_i,4])})

				//Pulando Registro
			Next _i

			//Ativando o arquivo e gerando o xml
			oFWMsExcel:Activate()
			oFWMsExcel:GetXMLFile(cArquivo)

			//Abrindo o excel e abrindo o arquivo xml
			oExcel := MsExcel():New()
			oExcel:WorkBooks:Open(cArquivo)
			oExcel:SetVisible(.T.)
			oExcel:Destroy()

			XAG0155->(DbCloseArea())
			RestArea(aArea)
		ENDIF
	ENDIF
Return
