#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR142   ºAutor  ³Microsiga           º Data ³  09/21/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para exportar dados da base quente para Backup   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR142()
	Processa({|| Roda()})
Return

Static Function Roda()
   
		aSX3ZZ5     := ACO->(DbStruct())	
      cEmpresa    := SM0->M0_CODIGO+'0'
      cddmmaahhmm := Substr(Dtos(ddatabase),7,2)+Substr(Dtos(ddatabase),5,2)+Substr(Dtos(ddatabase),3,2)+Substr(Time(),1,2)+Substr(Time(),4,2)
	
		cQuery := ""
		cQuery += "SELECT * " 
		cQuery += "FROM "+RetSqlName("ACO")+" (NOLOCK) "
		cQuery += "WHERE D_E_L_E_T_ <> '*' "
	
		If (Select("MACO") <> 0)
			DbSelectArea("MACO")
			DbCloseArea()
		Endif       

		TCQuery cQuery NEW ALIAS "MACO"
		                       
		For aa := 1 to Len(aSX3ZZ5)
			If aSX3ZZ5[aa,2] <> "C"
				TcSetField("MACO",aSX3ZZ5[aa,1],aSX3ZZ5[aa,2],aSX3ZZ5[aa,3],aSX3ZZ5[aa,4])		
			EndIf
		Next aa
	
		DbSelectArea("MACO")    
		COPY TO 'ACO'+cEmpresa+cddmmaahhmm
		     
		cDir     := '\SIGAADV\'
		cArquivo := 'ACO'+cEmpresa+cddmmaahhmm+'.dbf'
		If File(cDir+cArquivo)
			cArq3	:= '\SIGAADV\ACO'+cEmpresa+cddmmaahhmm+'.dbf'
			cBkpArq3 := 'C:\BkpPreco\AC0'+cEmpresa+cddmmaahhmm+'.dbf'
			copy file &(cArq3) to &(cBkpArq3)
			delete file &(cArq3)
		Endif	

		aSX3ZZ5 := ACP->(DbStruct())	
	
		cQuery := ""
		cQuery += "SELECT * " 
		cQuery += "FROM "+RetSqlName("ACP")+" (NOLOCK) "
		cQuery += "WHERE D_E_L_E_T_ <> '*' "
	
		If (Select("MACP") <> 0)
			DbSelectArea("MACP")
			DbCloseArea()
		Endif       

		TCQuery cQuery NEW ALIAS "MACP"
		                       
		For aa := 1 to Len(aSX3ZZ5)
			If aSX3ZZ5[aa,2] <> "C"
				TcSetField("MACP",aSX3ZZ5[aa,1],aSX3ZZ5[aa,2],aSX3ZZ5[aa,3],aSX3ZZ5[aa,4])		
			EndIf
		Next aa
	
		DbSelectArea("MACP")    
		COPY TO 'ACP'+cEmpresa+cddmmaahhmm
		     
		cDir     := '\SIGAADV\'
		cArquivo := 'ACP'+cEmpresa+cddmmaahhmm+'.dbf'
		If File(cDir+cArquivo)
			cArq3	:= '\SIGAADV\ACP'+cEmpresa+cddmmaahhmm+'.dbf'
			cBkpArq3 := 'C:\BkpPreco\ACP'+cEmpresa+cddmmaahhmm+'.dbf'
			Copy file &(cArq3) to &(cBkpArq3)
			delete file &(cArq3)
		Endif	
   
Return