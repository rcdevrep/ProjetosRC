#include 'protheus.ch'
#include 'topconn.ch'
                                    
/*/{Protheus.doc} XAG0079
//Criação de Clientes e contas - será utilizado para copiar em novas filiais
@author Spiller
@since 04/08/2021
@version undefined
@param
@type function
/*/
User function XAG0079()
   
    Local cQuery       := ""
    Local cTipo        := ""  
    Local cRazao  	   := ""  
	Local cAliasSX3    := "SX3"
	Local cNovoCli     := ""
	Local _i           := 0 
	Local cRetorno     := ""
	Private  aCampos := {}
   
   	cRetorno := FWInputBox("Qual tabela deseja copiar? ", "")

	If !(alltrim(cRetorno) $ 'SA1/SA2' )
	 	alert('SOMENTE HABILITADO PARA TABELAS SA1 E SA2')
		Return 
	Else 
		cTipo := alltrim(cRetorno)
	Endif  

   //Varre SX3 e pega todos os campos da SA1 
	DbSelectArea(cAliasSX3)
	(cAliasSX3)->(DbSetOrder(1))
	If Dbseek(cTipo)
		While (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_ARQUIVO")))) == cTipo
		
			//aadd(aCampos, (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CAMPO")))))
			If (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CONTEXT")))) <> 'V'
				AADD(aCampos,{;
				TRIM((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TITULO"))))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CAMPO")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_PICTURE")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TAMANHO")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_DECIMAL")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_VALID")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_USADO")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TIPO")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_F3")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CONTEXT")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CBOX")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_RELACAO"))))})
			Endif 
			(cAliasSX3)->(dbskip())
		Enddo 
	Endif 

 

	//empresas 01 / 15 / 11 / 12 / 16 
	//Levantar faturamento cliente dos ultimos 24 meses com conta genérica 112010001.	
    If !(cEmpant $ '01/11/15/12/16')
        alert('Empresas permitidas: 01/15/11/12/16')
    	Return	
    Endif     

    
	//Lista da Clientes com Faturamento desde ano passado                 
	/*cQuery := " SELECT A1_COD,A1_LOJA,A1_NOME,A1_CONTA,A1_CGC FROM SF2"+cEmpant+"0 F2 (NOLOCK)" 
	cQuery += " INNER JOIN SA1"+cEmpant+"0 A1 (NOLOCK) ON  A1_COD = F2_CLIENTE AND F2_LOJA = A1_LOJA AND A1.D_E_L_E_T_ = '' " 
	cQuery += " WHERE F2_EMISSAO >= '"+dtos(dDtDe)+"'  AND F2.D_E_L_E_T_ = '' AND LEN(A1_CGC) > 11  "
	cQuery += " AND A1_CONTA = '112010001' " 
	//Testes 
	//cQuery += " AND A1_COD = '00029 '"
	cQuery += " GROUP BY A1_COD,A1_LOJA,A1_NOME,A1_CONTA,A1_CGC  " */
	If cTipo == 'SA1'
		If cEmpAnt == '01'
			cQuery += " SELECT * "//TOP 1 * "
			cQuery += " FROM SA1110 A  (NOLOCK) "
			cQuery += " WHERE  A1_MSBLQL <>  '1' "
			cQuery += " AND    D_E_L_E_T_ <> '*' "
			cQuery += " AND A1_ULTCOM >   '20190804' "
			cQuery += " AND  EXISTS (SELECT 1 FROM SF2110 B (NOLOCK) "
			cQuery += "WHERE F2_CLIENT = A1_COD "
				cQuery += "AND F2_LOJA = A1_LOJA "
				cQuery += "AND B.D_E_L_E_T_ <> '*' "
				cQuery += "AND F2_EMISSAO >  '20190804' "
				cQuery += " AND F2_TIPO =  'N') "
			cQuery += " AND NOT EXISTS (SELECT * FROM SA1010 C (NOLOCK) "
			cQuery += "         WHERE C.D_E_L_E_T_ <> '*' "
			cQuery += "         AND  A.A1_CGC = C.A1_CGC) "
		Elseif cEmpant == '15'
			cQuery += "SELECT * "
			cQuery += " FROM SA1110 A  (NOLOCK) "
			cQuery += " WHERE  A1_MSBLQL <>  '1' "
			cQuery += " AND    D_E_L_E_T_ <> '*' "
			cQuery += "AND A1_ULTCOM >   '20190804' "
			cQuery += " AND  EXISTS (SELECT 1 FROM SF2110 B (NOLOCK) "
			cQuery += "WHERE F2_CLIENT = A1_COD "
			cQuery += "	AND F2_LOJA = A1_LOJA "
			cQuery += "	AND B.D_E_L_E_T_ <> '*' "
			cQuery += "	AND F2_EMISSAO >  '20190804' "
			cQuery += "	AND F2_TIPO =  'N'  AND (A1_VEND3 = 'RC0026' OR  A1_VEND7 = 'RC0026')) "
			cQuery += " AND NOT EXISTS (SELECT * FROM SA1150 C (NOLOCK) "
			cQuery += "       WHERE C.D_E_L_E_T_ <> '*' "
			cQuery += "      AND  A.A1_CGC = C.A1_CGC) "
		Endif 

	Elseif cTipo == 'SA2'
		cQuery += " SELECT  * "
		cQuery += " FROM SA2110 A  (NOLOCK) "
		cQuery += " WHERE  A2_MSBLQL <>  '1' "
		cQuery += " AND    D_E_L_E_T_ <> '*' AND A2_CGC = '02419762940' "
		//cQuery += " AND  EXISTS (SELECT 1 FROM SF1110 B (NOLOCK) "
		//cQuery += "            WHERE F1_FORNECE= A2_COD  "
		//cQuery += "                      AND F1_LOJA = A2_LOJA "
		//cQuery += "                      AND B.D_E_L_E_T_ <> '*' "
		//cQuery += "                      AND F1_EMISSAO >  '20190804' "
		//cQuery += "                        AND F1_TIPO =  'N') "
		cQuery += " AND NOT EXISTS (SELECT * FROM SA2010 C (NOLOCK) "
		cQuery += "              WHERE C.D_E_L_E_T_ <> '*' "
		cQuery += "                       AND   A.A2_CGC = C.A2_CGC) "

	Endif 
     
   	//Conout(cQuery)   
    If Select("XAG0079") <> 0
 		dbSelectArea("XAG0079")
		XAG0079->(dbCloseArea())
    Endif

	TCQuery cQuery NEW ALIAS "XAG0079"   

	//Elimina campos que nao existem
	dbselectarea('XAG0079')
	For _i := len(aCampos) to 1 step -1
		
			cCampo := aCampos[_i][2]
			If Type( cCampo ) == 'U'  
				aCampos[_i][2] := ""//ADel( aCampos , _i )	
			Endif 
	Next _i

	_ntotReg := 0         
	While  XAG0079->(!eof())
   		_ntotReg++ //:= XAG0079->(LASTREC()) 
   		XAG0079->(dbskip())
  	Enddo
  	
  	//Mensagem de confirmação  
	If !MsgYesNo(" Serão geradas "+alltrim(str(_ntotReg))+" novas Contas, Confirma?")
       	Return
    Endif  
    
    XAG0079->(Dbgotop())
	
    While  XAG0079->(!eof())

        If cTipo == 'SA1' 
			cNovoCli := CriaSa1()

			If  alltrim(cNovoCli) <> ''

				//cTipo  	:= 'SA1'
				cRazao 	:=  SUBSTR(alltrim(SA1->A1_NOME),1,40)
				cNovaconta := ""                                     
				
				//Rotina de Inclusão de conta contábil  
				cNovaconta:= U_X635CONT(cRazao,cTipo)
				
				Conout('XAG0079')  
				Conout(cNovaconta)
				//Se criou a Conta corretamente Grava na SA1
				Dbselectarea('CT1')
				DbSetorder(1) 
				If Dbseek(xfilial('CT1')+cNovaconta   )  
					Conout('CT1 - XAG0079')  
					Conout(CT1->CT1_CONTA)
					Dbselectarea('SA1')
					Dbsetorder(1) 
					If DbSeek(xFilial('SA1')+SA1->A1_COD+SA1->A1_LOJA)
						Reclock('SA1',.F.)
							SA1->A1_CONTA := cNovaconta
						SA1->(MsUnlock()) 
					Else
						Conout('Erro SA1 nao Localizada:  '+cNovaconta+' - '+alltrim(SA1->A1_NOME))
					Endif  
					Conout('SA1- XAG0079')  
					Conout(SA1->A1_CONTA)       
				Else
					Conout('Erro ao Gerar conta '+cNovaconta+' - '+alltrim(SA1->A1_NOME))
				Endif
			Endif 
		elseif cTipo = 'SA2' 
			
			cNovoforn := CriaSa2()

			If  alltrim(cNovoforn) <> ''

				//cTipo  	:= 'SA1'
				cRazao 	:=  alltrim(SA2->A2_NOME)
				cNovaconta := ""                                     
				
				//Rotina de Inclusão de conta contábil  
				cNovaconta:= U_X635CONT(cRazao,cTipo)
				
				Conout('XAG0079')  
				Conout(cNovaconta)
				//Se criou a Conta corretamente Grava na SA1
				Dbselectarea('CT1')
				DbSetorder(1) 
				If Dbseek(xfilial('CT1')+cNovaconta   )  
					Conout('CT1 - XAG0079')  
					Conout(CT1->CT1_CONTA)
					Dbselectarea('SA2')
					Dbsetorder(1) 
					If DbSeek(xFilial('SA2')+SA2->A2_COD+SA2->A2_LOJA)
						Reclock('SA2',.F.)
							SA2->A2_CONTA := cNovaconta
						SA2->(MsUnlock()) 
					Else
						Conout('Erro SA2 nao Localizada:  '+cNovaconta+' - '+alltrim(SA2->A2_NOME))
					Endif  
					Conout('SA2- XAG0079')  
					Conout(SA2->A2_CONTA)       
				Else
					Conout('Erro ao Gerar conta '+cNovaconta+' - '+alltrim(SA2->A2_NOME))
				Endif
			Endif 
			
		Endif 

		XAG0079->(dbskip())
    Enddo
    
Return 

Static Function CriaSA1()

	Local cCodNovo  := ""
	local cLojaNovo := ""
	Local _i        := 0 
	Local cCampo    := ""

	cTpPessoa := IIf(XAG0079->A1_PESSOA == "F", "F", "J")

	If (cTpPessoa == "F")
		cCodNovo   := SA1NovoCod()
		cLojaNovo  := "01"
	Else
		cCGCBase := SubStr(XAG0079->(A1_CGC), 1, 8)
		aUltCdLj := SA1UltLoja(cCGCBase)

		If (Len(aUltCdLj) == 2)
			cCodNovo   := aUltCdLj[1]
			cLojaNovo  := aUltCdLj[2]
		Else
			cCodNovo   := SA1NovoCod()
			cLojaNovo  := "01"
		EndIf
	EndIf  

	Dbselectarea('SA1')
	If cCodNovo <> ""
		Reclock('SA1',.T.)
		For _i := 1 to len(aCampos)
			
			cCampo := aCampos[_i][2]
			If alltrim(cCampo) <> ""
				//Conout(cCampo)
				If alltrim(cCampo) == 'A1_COD'
					SA1->A1_COD := cCodNovo
				Elseif alltrim(cCampo) == 'A1_LOJA'
					SA1->A1_LOJA := cLojaNovo
				Else
					//se for data formata
					If ALLTRIM(aCampos[_i][8]) == 'D'
						SA1->&(aCampos[_i][2]) := stod(XAG0079->&(aCampos[_i][2]))
					Else 
						SA1->&(aCampos[_i][2]) := XAG0079->&(aCampos[_i][2])
					Endif 
				Endif 
				//Conout(SA1->&(aCampos[_i][2]) )
			Endif 
		Next _i

		SA1->A1_ORIIMP = 'XAG0079'

		SA1->(msunlock())

		Conout(SA1->A1_COD + ';'+ SA1->A1_LOJA +';'+  SA1->A1_CGC +';'+ SA1->A1_NOME )

	Endif 


Return cCodNovo+cLojaNovo




Static Function CriaSA2()

	Local cCodNovo  := ""
	local cLojaNovo := ""
	Local _i        := 0 
	Local cCampo    := ""

	cTpPessoa := IIf(XAG0079->A2_TIPO == "F", "F", "J")

	If (cTpPessoa == "F")
		cCodNovo   := SA2NovoCod()
		cLojaNovo  := "01"
	Else
		cCGCBase := SubStr(XAG0079->(A2_CGC), 1, 8)
		aUltCdLj := SA2UltLoja(cCGCBase)

		If (Len(aUltCdLj) == 2)
			cCodNovo   := aUltCdLj[1]
			cLojaNovo  := aUltCdLj[2]
		Else
			cCodNovo   := SA2NovoCod()
			cLojaNovo  := "01"
		EndIf
	EndIf  

	Dbselectarea('SA2')
	If cCodNovo <> ""
		Reclock('SA2',.T.)
		For _i := 1 to len(aCampos)
			
			cCampo := aCampos[_i][2]
			If alltrim(cCampo) <> ""
				//Conout(cCampo)
				If alltrim(cCampo) == 'A2_COD'
					SA2->A2_COD := cCodNovo
				Elseif alltrim(cCampo) == 'A2_LOJA'
					SA2->A2_LOJA := cLojaNovo
				Else
					//se for data formata
					If ALLTRIM(aCampos[_i][8]) == 'D'
						SA2->&(aCampos[_i][2]) := stod(XAG0079->&(aCampos[_i][2]))
					Else 
						SA2->&(aCampos[_i][2]) := XAG0079->&(aCampos[_i][2])
					Endif 
				Endif 
				//Conout(SA1->&(aCampos[_i][2]) )
			Endif 
		Next _i

		SA2->A2_ORIIMP = 'XAG0079'

		SA2->(msunlock())

		Conout(SA2->A2_COD + ';'+ SA2->A2_LOJA +';'+  SA2->A2_CGC +';'+ SA2->A2_NOME )

	Endif 


Return cCodNovo+cLojaNovo


//Pega proximo código válido
Static Function SA1NovoCod()

	Local cX3_Relacao := ""
	Local cCodNovo    := ""
	Local lJaExiste   := .T.

	cX3_Relacao := GetSx3Cache("A1_COD", "X3_RELACAO")

	While (lJaExiste)

		If __lSX8
			ConfirmSX8()
		EndIf

		If !(Empty(cX3_Relacao))
			cCodNovo := (&cX3_Relacao)
		Else
			cCodNovo := GetSXENum("SA1", "A1_COD")
		EndIf

		SA1->(DbSetOrder(1))
		SA1->(DbGoTop())
		lJaExiste := SA1->(DbSeek(xFilial("SA1")+cCodNovo))
	End

Return(cCodNovo)


Static Function SA2NovoCod()

	Local cX3_Relacao := ""
	Local cCodNovo    := ""
	Local lJaExiste   := .T.

	cX3_Relacao := GetSx3Cache("A2_COD", "X3_RELACAO")

	While (lJaExiste)

		If __lSX8
			ConfirmSX8()
		EndIf

		If !(Empty(cX3_Relacao))
			cCodNovo := (&cX3_Relacao)
		Else
			cCodNovo := GetSXENum("SA2", "A2_COD")
		EndIf

		SA2->(DbSetOrder(1))
		SA2->(DbGoTop())
		lJaExiste := SA2->(DbSeek(xFilial("SA2")+cCodNovo))
	End

Return(cCodNovo)   

//Valida ultima Loja 
Static Function SA1UltLoja(cCGCBase)

	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()
	Local cLoja     := ""
	Local aRet      := {}

	cQuery += " SELECT SA1.A1_COD, "
	cQuery += " MAX(SA1.A1_LOJA) AS A1_LOJA "
	cQuery += " FROM " + RetSQLName("SA1") + " SA1 (NOLOCK) "
	cQuery += " WHERE SA1.D_E_L_E_T_ = '' "
	cQuery += " AND   SA1.A1_CGC LIKE '" + cCGCBase + "%' "
	cQuery += " GROUP BY SA1.A1_COD "

	TCQuery cQuery NEW ALIAS (cAliasQry)

	If !Empty((cAliasQry)->(A1_COD)) .And. !Empty((cAliasQry)->(A1_LOJA))
		aAdd(aRet, (cAliasQry)->(A1_COD))

		cLoja := Soma1((cAliasQry)->(A1_LOJA))
		aAdd(aRet, cLoja)
	EndIf

Return(aRet)

Static Function SA2UltLoja(cCGCBase)

	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()
	Local cLoja     := ""
	Local aRet      := {}

	cQuery += " SELECT SA2.A2_COD, "
	cQuery += " MAX(SA2.A2_LOJA) AS A2_LOJA "
	cQuery += " FROM " + RetSQLName("SA2") + " SA2 (NOLOCK) "
	cQuery += " WHERE SA2.D_E_L_E_T_ = '' "
	cQuery += " AND   SA2.A2_CGC LIKE '" + cCGCBase + "%' "
	cQuery += " GROUP BY SA2.A2_COD "

	TCQuery cQuery NEW ALIAS (cAliasQry)

	If !Empty((cAliasQry)->(A2_COD)) .And. !Empty((cAliasQry)->(A2_LOJA))
		aAdd(aRet, (cAliasQry)->(A2_COD))

		cLoja := Soma1((cAliasQry)->(A2_LOJA))
		aAdd(aRet, cLoja)
	EndIf

Return(aRet)    

/*
 --21101               
 SELECT * FROM CT1010
 WHERE -- CT1_CONTA = '112010001 ' 
 CT1_DESC01 LIKE '%FORNECEDOR%'      
 AND D_E_L_E_T_ = ''   

 --11201               
  SELECT * FROM CT1010
 WHERE -- CT1_CONTA = '112010001 ' 
 CT1_DESC01 LIKE '%CLIENTE%'      
 AND D_E_L_E_T_ = '' */
