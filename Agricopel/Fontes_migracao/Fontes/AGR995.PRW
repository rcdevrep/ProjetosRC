//#INCLUDE "PROTHEUS.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁIE        Ё Autor ЁEduardo Riera          Ё Data Ё10.12.2002Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁRotina de validacao do digito verificador da IE             Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁExpL: Indica se a Inscricao estadual eh valida              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁExpC1: Codigo da Inscricao estadual                         Ё╠╠
╠╠Ё          ЁExpL2: Unidade Federativa                                   Ё╠╠
╠╠Ё          ЁExpL3: Indica se o help devera ser demonstrado         (OPC)Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao Efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

#DEFINE TCD_UF     01
#DEFINE TCD_TAM    02
#DEFINE TCD_FATF   03
#DEFINE TCD_DVXROT 04
#DEFINE TCD_DVXMD  05
#DEFINE TCD_DVXTP  06
#DEFINE TCD_DVYROT 07
#DEFINE TCD_DVYMD  08
#DEFINE TCD_DVYTP  09
#DEFINE TCD_DIG14  10
#DEFINE TCD_DIG13  11
#DEFINE TCD_DIG12  12
#DEFINE TCD_DIG11  13
#DEFINE TCD_DIG10  14
#DEFINE TCD_DIG09  15
#DEFINE TCD_DIG08  16
#DEFINE TCD_DIG07  17
#DEFINE TCD_DIG06  18
#DEFINE TCD_DIG05  19
#DEFINE TCD_DIG04  20
#DEFINE TCD_DIG03  21
#DEFINE TCD_DIG02  22
#DEFINE TCD_DIG01  23
#DEFINE TCD_CRIT   24

//User Function IEGRA(cIE,cUF,lHelp)
User Function AGR995       



cIE := IIF(FUNNAME()=="MATA030" .or. FUNNAME()=="MATA920"  ,M->A1_INSCR,M->A2_INSCR)
cUF := IIF(FUNNAME()=="MATA030" .or. FUNNAME()=="MATA920",M->A1_EST,M->A2_EST)

aPesos   := {}
aDigitos := {}
aCalculo := {}
aMi      := {}
nX       := 0
nY       := 0
nDVX     := 0
nDVY     := 0                                                                                                    
nPUF     := 0
nPPeso   := 0
nSomaS   := 0
cDigito  := ""
cDVX     := ""
cDVY     := ""
lRetorno := .T.

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁAjusta o codigo da Inscricao Estadual                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cIE := AllTrim(cIE)
cIE := StrTran(cIE,".","")
cIE := StrTran(cIE,"/","")
cIE := StrTran(cIE,"-","")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁMontagem da Tabela de Calculo                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(cIE) .And. !"ISENT"$cIE
	aadd(aCalculo,{"AC",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=0","=1","09","09","09","09","09","09","DVX",{||Len(cIE)==09}})
	aadd(aCalculo,{"AC",13,00,"E ",11,"P02","E ",11,"P01","--","=0","=1","09","09","09","09","09","09","09","09","09","DVX","DVY",{||Len(cIE)==13}})
	aadd(aCalculo,{"AL",09,00,"BD",11,"P01","  ",00,"   ","--","--","--","--","--","=2","=4","=03578","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"AP",09,00,"CE",11,"P01","  ",00,"   ","--","--","--","--","--","=0","=3","09","09","09","09","09","09","DVX",{||cIE<="030170009"}})
	aadd(aCalculo,{"AP",09,01,"CE",11,"P01","  ",00,"   ","--","--","--","--","--","=0","=3","09","09","09","09","09","09","DVX",{||cIE>="030170010".And.cIE<="030190229"}})
	aadd(aCalculo,{"AP",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=0","=3","09","09","09","09","09","09","DVX",{||cIE>="030190230"}})
	aadd(aCalculo,{"AM",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=0","=47","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"BA",08,00,"E ",10,"P02","E ",10,"P03","--","--","--","--","--","--","09","09","09","09","09","09","DVY","DVX",{||SubStr(cIE,1,1)$"0123458"}})
	aadd(aCalculo,{"BA",08,00,"E ",11,"P02","E ",11,"P03","--","--","--","--","--","--","09","09","09","09","09","09","DVY","DVX",{||SubStr(cIE,1,1)$"679"}})
	aadd(aCalculo,{"CE",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=0","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"DF",13,00,"E ",11,"P02","E ",11,"P01","--","=0","=7","=34","09","09","09","09","09","09","09","09","DVX","DVY",{||.T.}})
	aadd(aCalculo,{"ES",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=0","=08","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"GO",09,01,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=1","=015","09","09","09","09","09","09","DVX",{||cIE>="101031050".And.cIE<="101199979"}})
	aadd(aCalculo,{"GO",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=1","=015","09","09","09","09","09","09","DVX",{||!(cIE>="101031050".And.cIE<="101199979")}})
	aadd(aCalculo,{"MA",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=1","=2","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"MT",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","09","09","09","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"MS",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=2","=8","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"MG",13,00,"AE",10,"P10","E ",11,"P11","--","09","09","09","09","09","09","09","09","09","09","09","DVX","DVY",{||.T.}})
	aadd(aCalculo,{"PA",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=1","=5","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"PB",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=1","=6","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"PR",10,00,"E ",11,"P09","E ",11,"P08","--","--","--","--","09","09","09","09","09","09","09","09","DVX","DVY",{||.T.}})
	aadd(aCalculo,{"PE",14,01,"E ",11,"P07","  ",00,"   ","=1","=8","19","09","09","09","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"PI",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=1","=9","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"RJ",08,00,"E ",11,"P08","  ",00,"   ","--","--","--","--","--","--","=1789","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"RN",09,00,"BD",11,"P01","  ",00,"   ","--","--","--","--","--","=2","=0","03","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"RS",10,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","04","09","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"RO",09,01,"E ",11,"P04","  ",00,"   ","--","--","--","--","--","19","09","09","09","09","09","09","09","DVX",{||Len(cIE)==9}})
	aadd(aCalculo,{"RO",14,01,"E ",11,"P01","  ",00,"   ","09","09","09","09","09","09","09","09","09","09","09","09","09","DVX",{||Len(cIE)==14}})
	aadd(aCalculo,{"RR",09,00,"D ",09,"P05","  ",00,"   ","--","--","--","--","--","=2","=4","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"SC",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","09","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"SP",12,00,"D ",11,"P12","D ",11,"P13","--","--","09","09","09","09","09","09","09","09","DVX","09","09","DVY",{||SubStr(cIE,1,1)<>"P"}})
	aadd(aCalculo,{"SP",13,00,"D ",11,"P12","  ",00,"   ","--","=P","09","09","09","09","09","09","09","09","DVX","09","09","09",{||SubStr(cIE,1,1)=="P"}})
	aadd(aCalculo,{"SE",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","09","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"TO",11,00,"E ",11,"P06","  ",00,"   ","--","--","--","=2","=9","=09","=1239","09","09","09","09","09","09","DVX",{||.T.}})
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁMontagem da Tabela de Pesos                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aadd(aPesos,{06,05,04,03,02,09,08,07,06,05,04,03,02,00}) //01
	aadd(aPesos,{05,04,03,02,09,08,07,06,05,04,03,02,00,00}) //02
	aadd(aPesos,{06,05,04,03,02,09,08,07,06,05,04,03,00,02}) //03
	aadd(aPesos,{00,00,00,00,00,00,00,00,06,05,04,03,02,00}) //04
	aadd(aPesos,{00,00,00,00,00,01,02,03,04,05,06,07,08,00}) //05
	aadd(aPesos,{00,00,00,09,08,00,00,07,06,05,04,03,02,00}) //06
	aadd(aPesos,{05,04,03,02,01,09,08,07,06,05,04,03,02,00}) //07
	aadd(aPesos,{08,07,06,05,04,03,02,07,06,05,04,03,02,00}) //08
	aadd(aPesos,{07,06,05,04,03,02,07,06,05,04,03,02,00,00}) //09
	aadd(aPesos,{00,01,02,01,01,02,01,02,01,02,01,02,00,00}) //10
	aadd(aPesos,{00,03,02,11,10,09,08,07,06,05,04,03,02,00}) //11
	aadd(aPesos,{00,00,01,03,04,05,06,07,08,10,00,00,00,00}) //12
	aadd(aPesos,{00,00,03,02,10,09,08,07,06,05,04,03,02,00}) //13
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁValidacao dos digitos da inscricao estadual                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nPUF := aScan(aCalculo,{|x| x[TCD_UF] == cUF .And. Eval(x[TCD_CRIT])})
	If nPUF <> 0
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁValidacao do Tamanho da inscricao estadual                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If aCalculo[nPUF][2] <> Len(cIE)
			lRetorno := .F.
		Else
			nY := TCD_DIG01+1
			For nX := Len(cIE) To 1 STEP - 1
				cDigito := SubStr(cIE,nX,1)	
				nY--
				Do Case
				Case SubStr(aCalculo[nPUF][nY],1,2)=="DV"
					If SubStr(aCalculo[nPUF][nY],1,3)=="DVX"
						cDVX := cDigito
					Else
						cDVY := cDigito
					EndIf
				Case SubStr(aCalculo[nPUF][nY],1,2)=="--"
					lRetorno := .F.
					Exit
				Case SubStr(aCalculo[nPUF][nY],1,1)=="="
					If !cDigito $ SubStr(aCalculo[nPUF][nY],2)
						lRetorno := .F.
						Exit
					EndIf
				OtherWise
					If !(cDigito >= SubStr(aCalculo[nPUF][nY],1,1) .And. cDigito <= SubStr(aCalculo[nPUF][nY],2,1))
						lRetorno := .F.
						Exit
					EndIf
				EndCase
				aadd(aDigitos,cDigito)
			Next nX
		EndIf
	Else
		lRetorno := .F.
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁCalculo do digito verificador DVX                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lRetorno
		nPPeso := Val(SubStr(aCalculo[nPUF][TCD_DVXTP],2))
		nSomaS := 0
		aMI    := {}
		For nX := 1 To Len(aDigitos)
			aadd(aMi,Val(aDigitos[nX])*aPesos[nPPeso][15-nX])
			nSomaS += Val(aDigitos[nX])*aPesos[nPPeso][15-nX]
		Next nX	
		If "A"$aCalculo[nPUF][TCD_DVXROT]
			For nX := 1 To Len(aMi)				
				nSomaS += Int(aMi[nX] / 10)
			Next nX
		EndIf
		If "B"$aCalculo[nPUF][TCD_DVXROT]
			nSomaS *= 10
		EndIf
		If "C"$aCalculo[nPUF][TCD_DVXROT]
			nSomaS *= 5+4*aCalculo[nPUF][TCD_FATF]
		EndIf
		If "D"$aCalculo[nPUF][TCD_DVXROT]
			nDVX := Mod(nSomaS,aCalculo[nPUF][TCD_DVXMD])
		EndIf
		If "E"$aCalculo[nPUF][TCD_DVXROT]
			nDVX := aCalculo[nPUF][TCD_DVXMD]-Mod(nSomaS,aCalculo[nPUF][TCD_DVXMD])
		EndIf
		If nDVX == 10
			nDVX := 0
		EndIf
		If nDVX == 11
			nDVX := aCalculo[nPUF][TCD_FATF]
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁCalculo do digito verificador DVY                                       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !Empty(aCalculo[nPUF][TCD_DVYROT])
			nPPeso := Val(SubStr(aCalculo[nPUF][TCD_DVYTP],2))
			nSomaS := 0
			aMi    := {}
			For nX := 1 To Len(aDigitos)
				aadd(aMi,Val(aDigitos[nX])*aPesos[nPPeso][15-nX])
				nSomaS += Val(aDigitos[nX])*aPesos[nPPeso][15-nX]
			Next nX	
			If "A"$aCalculo[nPUF][TCD_DVYROT]
				For nX := 1 To Len(aMi)				
					nSomaS += Int(aMi[nX] / 10)
				Next nX
			EndIf
			If "B"$aCalculo[nPUF][TCD_DVYROT]
				nSomaS *= 10
			EndIf
			If "C"$aCalculo[nPUF][TCD_DVYROT]
				nSomaS *= 5+4*aCalculo[nPUF][TCD_FATF]
			EndIf
			If "D"$aCalculo[nPUF][TCD_DVYROT]
				nDVY := Mod(nSomaS,aCalculo[nPUF][TCD_DVYMD])
			EndIf
			If "E"$aCalculo[nPUF][TCD_DVYROT]
				nDVY := aCalculo[nPUF][TCD_DVYMD]-Mod(nSomaS,aCalculo[nPUF][TCD_DVYMD])
			EndIf
			If nDVY == 10
				nDVY := 0
			EndIf
			If nDVY == 11
				nDVY := aCalculo[nPUF][TCD_FATF]
			EndIf
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁVerificacao dos digitos calculados                                      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Val(cDVX) <> nDVX .Or. Val(cDVY) <> nDVY
			lRetorno := .F.
		EndIf
	EndIf
EndIf   

If !lRetorno
//	Help(" ",1,"IE")
	Alert("Inscricao Invalida") 
EndIf  

Return (lRetorno)
