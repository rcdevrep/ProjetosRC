/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³S301CF    ºAutor  ³Airton Nakamura     º Data ³  09/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada na importacao de dados do palm             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function S301CF()

Local cUFEmp 	:= Upper(Alltrim(GetMv("MV_ESTADO")))
Local cCodShell := Alltrim(GetMv("MV_CODSHEL"))
Local cCodMann  := Alltrim(GetMv("MV_CODMANN"))

/*If SB1->B1_PROC == cCodMann .And. SA1->A1_TIPO == "R"
	cTES := "504"
	cCFO := "5405"
Endif     */

If SB1->B1_PROC == cCodShell
	cTES := "506"
//	cCFO := "5656"
Endif

If SB1->B1_PROC == cCodShell .And. SA1->A1_TIPO == "R"
	cTES := "507"
 	cCFO := "5655"
Endif     

If SB1->B1_PROC == cCodShell .And. SA1->A1_TIPO == "F"
	cTES := "506"
//	cCFO := "5656"
Endif     

If SC6->C6_TES == "608"
	cCFO := "5910"
Endif     */

/*If cFilAnt == "04" .AND. SubStr(TRBPED->CLIENTE,1,6) == "007918"
	cTES := "509"
	cCFO := "5663"
Endif */ 
//bops124990
//If cFilAnt == "01" .AND. SA1->A1_TIPO == "S"
//	cTES := "501"
//	cCFO := "5655"
//Endif
//fim 

/*If cFilAnt == "02" .AND. Upper(SA1->A1_EST) != cUFEmp

	cTES := If(SA1->A1_TIPO <> "R","717","721")
	cCFO := If(SA1->A1_TIPO <> "R","6655","6656")
Endif */

If SA1->A1_TIPO == "X"
	cCFO := "7"+Subs(cCFO,2,3)
ElseIf Upper(SA1->A1_EST) != cUFEmp
	cCFO := "6"+Subs(cCFO,2,3)
Endif

Return(Nil)