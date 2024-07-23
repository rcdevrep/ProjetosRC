#INCLUDE "PROTHEUS.CH"

User Function XAG0082()
	
	Local aUsers := FWSFAllUsers() // Array de todos os usu�rios
	Local aUsr
	Local nUser
	Local nGroup
	Local aGroups
	Local aGrpInfo
	Local aGrpMenu
	Local aUsrMenu
	Local cUsrRegra
	Local aAceMenu
	Local aUltAce
	Local aModulos := retModName()
	Local nI
	Local nPosMod
	
	Local aUsrGrp
	
	// Totais
	Local nTotUsr := 0
	Local aTotMod := {}
	Local nPosAux
	
	Local aRel := {}
	Local aRelAux := {}
	
	// Excel
	Local cArquivo
    Local oFWMSEx  := FWMsExcelEx():New()
    Local oExcel
	
	Local lStyle
	
	//Adiciona configurador
	
	AAdd(aModulos, {99, "SIGACFG", "Configurador", .F., "", 99, "", .F.})
	
	For nUser := 1 To Len(aUsers) // Percorre todos os usu�rios
		
		PswOrder(1)
		PswSeek(aUsers[nUser][2])
		
		aUsr := PswRet()
		
		If !aUsr[1][17] // N�o Bloqueado
			
			nTotUsr++
			
			aUltAce := FWUsrUltLog(aUsers[nUser][2])
			
			cUsrRegra := FWUsrGrpRule(aUsers[nUser][2]) //define o tipo de prioriza��o de grupo - cRet == 2: Desconsidera - cRet == 3: Soma
				
			aUsrMenu := FWUsrMenu(aUsers[nUser][2])
			
			aAceMenu := {}
			aUsrGrp  := {}
			
			For nI := 1 To Len(aUsrMenu)
				
				If SubStr(aUsrMenu[nI], 3) # "X"
					
					AAdd(aAceMenu, Left(aUsrMenu[nI], 2))
					
				EndIf
				
			Next nI
			
			If cUsrRegra # "2"
				
				aGroups := FWSFUsrGrps(aUsers[nUser][2]) // Array de todos os grupos do usu�rio
				
				For nGroup := 1 To Len(aGroups) // Percorre todos os grupos
					
					aGrpInfo := FWGrpParam(aGroups[nGroup])
					
					aGrpMenu := FwGrpMenu(aGroups[nGroup])
					
					AAdd(aUsrGrp, {aGroups[nGroup], aGrpInfo[1][2]})
					
					For nI := 1 To Len(aGrpMenu)
						
						If SubStr(aGrpMenu[nI], 3) # "X"
							
							nPosMod := AScan(aAceMenu, {|x| x == Left(aGrpMenu[nI], 2)})
							
							If nPosMod == 0
								
								AAdd(aAceMenu, Left(aGrpMenu[nI], 2))
								
							EndIf
							
						EndIf
						
					Next nI
					
				Next nGroup
				
			EndIf
			
			// aAceMenu -> C�digo dos m�dulos que o usu�rio tem acesso
			// aUsrGrp -> Grupos do Usu�rio
			// aUltAce -> �ltimo acesso
			
			For nI := 1 To Len(aAceMenu)
				
				nPosMod := AScan(aModulos, {|x| x[1] == Val(aAceMenu[nI])})
				nPosAux := AScan(aTotMod, {|x| x[1] == aAceMenu[nI]})
				
				If nPosAux > 0
					
					aTotMod[nPosAux][4]++
					
				Else
					
					If nPosMod > 0
						
						AAdd(aTotMod, {aAceMenu[nI], aModulos[nPosMod][2], aModulos[nPosMod][3], 1})
						
					EndIf
					
				EndIf
				
			Next nI
			
			// Adicionar no Array do Relat�rio
			// Usu�rio | Nome | Grupo | M�dulo
			
			AAdd(aRel, {})
			
			AAdd(ATail(aRel), aUsers[nUser][3])
			AAdd(ATail(aRel), aUsers[nUser][4])
			AAdd(ATail(aRel), "")
			AAdd(ATail(aRel), "")
			
			aRelAux := {}
			
			For nI := 1 To Len(aUsrGrp)
				
				AAdd(aRelAux, {"", "", aUsrGrp[nI][1] + " (" + aUsrGrp[nI][2] + ")", ""})
				
			Next nI
			
			For nI := 1 To Len(aAceMenu)
				
				nPosMod := AScan(aModulos, {|x| x[1] == Val(aAceMenu[nI])})
				
				If nI <= Len(aRelAux)
					
					aRelAux[nI][4] := aModulos[nPosMod][2] + " (" + aModulos[nPosMod][3] + ")"
					
				Else
					
					AAdd(aRelAux, {"", "", "", aModulos[nPosMod][2] + " (" + aModulos[nPosMod][3] + ")"})
					
				EndIf
				
			Next nI
			
			For nI := 1 To Len(aRelAux)
				
				AAdd(aRel, aRelAux[nI])
				
			Next nI
			
		EndIf
		
	Next nUser
	
	// Imprime Relat�rio
	
	If Len(aRel) > 0
		
		oFWMSEx:AddworkSheet("Acessos por Usuario")
	        
	        oFWMSEx:AddTable("Acessos por Usuario", "Acessos por Usuario")
	            //Adicionando as colunas
	            oFWMSEx:AddColumn("Acessos por Usuario", "Acessos por Usuario", "Usuario", 1, 1)
	            oFWMSEx:AddColumn("Acessos por Usuario", "Acessos por Usuario", "Nome", 1, 1)
	            oFWMSEx:AddColumn("Acessos por Usuario", "Acessos por Usuario", PadC("Grupo", 15), 1, 1)
	            oFWMSEx:AddColumn("Acessos por Usuario", "Acessos por Usuario", PadC("Modulo", 30), 1, 1)
		
		For nI := 1 To Len(aRel)
			
			lStyle := .F.
			
			If !Empty(aRel[nI][1])
				
				oFWMSEx:SetCelBgColor("#00FFAA")
				
				lStyle := .T.
				
			EndIf
			
			oFWMSEx:AddRow("Acessos por Usuario", "Acessos por Usuario", ;
			        	aRel[nI], IIf(lStyle, {1,2,3,4}, {}))
			        	
		Next nI
		
		oFWMSEx:AddworkSheet("Totais por Modulo")
	        
	        oFWMSEx:AddTable("Totais por Modulo", "Totais por Modulo")
	            //Adicionando as colunas
	            oFWMSEx:AddColumn("Totais por Modulo", "Totais por Modulo", "Modulo", 1, 1)
	            oFWMSEx:AddColumn("Totais por Modulo", "Totais por Modulo", "Total", 3, 1)
		
		For nI := 1 To Len(aTotMod)
			
			
			oFWMSEx:AddRow("Totais por Modulo", "Totais por Modulo", ;
			        	{aTotMod[nI][2] + " (" + aTotMod[nI][3] + ")", aTotMod[nI][4]}, {})
			
		Next nI
		
		// Gera Arquivo
		
		cArquivo := GetTempPath() + '\Acessos_usuarios_' + StrTran(Time(), ":", "") + '.xml'
		
		oFWMSEx:Activate()
		oFWMSEx:GetXMLFile(cArquivo)
		
		If ApOleClient("MsExcel")
		    
		    oExcel := MsExcel():New()
		    oExcel:WorkBooks:Open(cArquivo)
		    oExcel:SetVisible(.T.)
		    oExcel:Destroy()
			
		Else
			
			MsgAlert("N�o foi encontrado o Excel para abrir o relat�rio :(")
			
		EndIf
		
	Else
		
		Alert("Sem dados para imprimir.")
		
	EndIf
	
Return
