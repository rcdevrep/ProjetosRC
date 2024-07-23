#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "protheus.ch"

/*            
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX270      บAutor  ณRODRIGO SILVEIRA  บ Data ณ  30.06.08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ETIQUETAS DE ENDERECOS                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AGX409()
	Private cPerg := "AGX409"

	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Armaz้m de  ?","mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Armaz้m at้ ?","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Endere็o de ?","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SBE"})
	AADD(aRegistros,{cPerg,"04","Endere็o at้?","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SBE"})
	AADD(aRegistros,{cPerg,"05","Nํvel       ?","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	Pergunte(cPerg,.T.)

	U_ImpEtq()

Return()

User Function ImpEtq()

	cQuery := ""
	cQuery += "SELECT BE_LOCALIZ,BE_CODPRO, "
	cQuery += "(SELECT B1_DESC FROM " + RETSQLNAME("SB1") + " B1 WHERE B1.B1_FILIAL = '" + xFilial("SB1")
	cQuery += "' AND B1.B1_COD =  BE.BE_CODPRO AND B1.D_E_L_E_T_ <> '*') AS PRODESC,"
    cQuery += "(SELECT DC3_CODNOR FROM " + RETSQLNAME("DC3") + " DC3 WHERE DC3.DC3_FILIAL = '" + xFilial("DC3")
	cQuery += "' AND DC3.DC3_CODPRO = BE.BE_CODPRO AND DC3.DC3_ORDEM = '01' AND DC3.D_E_L_E_T_ <> '*' AND DC3_LOCAL = BE_LOCAL) AS NORMA "
	cQuery += "FROM " + RETSQLNAME("SBE+") + " AS BE "
	cQuery += "WHERE D_E_L_E_T_ <> '*' "
	cQuery += "AND BE.BE_LOCALIZ BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
	cQuery += "AND BE.BE_LOCAL  BETWEEN  '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cQuery += "AND BE.BE_FILIAL = '" + xFilial("SBE") + "' "

	If AllTrim(mv_par05) <> ""
		cQuery += "AND SUBSTRING(BE.BE_LOCALIZ,7,2) = '" + mv_par05 + "' "
	Endif

	cQuery += "ORDER BY BE_LOCALIZ "

	If (Select("QRY") <> 0)
		dbSelectArea("QRY")
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRY"

	dbSelectArea("QRY")
	ProcRegua(500)
	dbGoTop()
	While !Eof()

	   cQuery := "" 
	   cQuery += "SELECT DC2_LASTRO, DC2_CAMADA FROM " + RETSQLNAME("DC2") + " "
  	   cQuery += "WHERE DC2_CODNOR = '" + QRY->NORMA + "' "
  	   cQuery += "  AND DC2_FILIAL = '" + xFilial("DC2") + "' "
       cQuery += "  AND D_E_L_E_T_ <> '*' "
                                 
     	If (Select("QRY2") <> 0)
  			dbSelectArea("QRY2")
			dbCloseArea()
		Endif
		
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "QRY2"
		dbSelectArea("QRY2")
		dbGoTop()                                      
	
		//abre o controle da impressora termica
		//MSCBPRINTER("ALLEGRO","COM2:9600,N,8,0",,)   
   
		//MSCBPRINTER("OS 214","LPT1",,,.F.)    

		//Do Case
		//Case Alltrim(SM0->M0_CODFIL) == "02"
		//  MSCBPRINTER("OS 214","COM2:9600,N,8,0",,,.F.)
		//Case Alltrim(SM0->M0_CODFIL) == "01" .OR. Alltrim(SM0->M0_CODFIL) == "06"
		  MSCBPRINTER("OS 214","LPT1",,,.F.)    
		//EndCase
      dbSelectArea("QRY")      
      If ALLTRIM(QRY->BE_LOCALIZ) <> "" 
	      MSCBCHKSTATUS(.F.)
			MSCBBEGIN (1,4)   
				//	MSCBGRAFIC(2,3,"SIGA")                                                            
		//	   MSCBSAY(002,002,QRY->BE_LOCALIZ,"N","2","002,002")   
/*			   MSCBSAY(018,002,strzero(VAL(MV_PAR01),6),"N","2","005,005")  
  			   MSCBSAY(063,002,"VOL.:","N","2","002,002")      
			   MSCBSAY(078,002,strzero(VAL(MV_PAR02),3),"N","2","005,005")  
			   MSCBLineH(001, 015, 100 ) 
			   MSCBSAY(022,016,"FONE: O8OO-643-8O88","N","2","002,001") */
			   
			   cVarAux := ""      
			   If ALLTRIM(QRY->BE_CODPRO) <> ""
				   cVarAux := ALLTRIM(QRY->BE_CODPRO) + "-"+  ALLTRIM(QRY->PRODESC)
   			   MSCBSAY(003,005,cVarAux,"N","7","001,001")  
            EndIf
			   cVarNor := ""
			   If QRY2->DC2_LASTRO <> 0
				   cVarNor := "NORMA " + ALLTRIM(STR(QRY2->DC2_LASTRO)) + " X " +  ALLTRIM(STR(QRY2->DC2_CAMADA))
    			   MSCBSAY(003,010,cVarNor,"N","7","001,001")  
            EndIf
            
   		   MSCBLineH(001, 018, 105 ) 
			   MSCBSAY(002,021,QRY->BE_LOCALIZ,"N","6","002,001") 
			MSCBEND()  
			MSCBWrite("<STX>f320<CR>")
			MSCBCLOSEPRINTER()
      EndIf
	  	QRY->(dbskip())
	EndDo    
Return()     